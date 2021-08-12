---
title: "Managed Node Group"
date: 2021-05-26T00:00:00-03:00
weight: 90
draft: false
---

### Managed Node Group with Bottlerocket

Instances in a managed node group by default use the latest version of Amazon EKS optimized Amazon Linux AMI. There are standard and GPU variants of the AMI but Bottlerocket is not natively supported as a built-in OS choice for managed node groups [yet](https://github.com/bottlerocket-os/bottlerocket/issues/911).

In this section, we will use [launch templates](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchTemplates.html) to create a managed node group with Bottlerocket nodes.

Let us select the AMI to use from [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/index.html) and save some information about the EKS cluster that is already running.

```bash
cd ~/environment
BOTTLEROCKET_AMI=$(aws ssm get-parameter --region $AWS_REGION --name "/aws/service/bottlerocket/aws-k8s-1.19/x86_64/latest/image_id" --query Parameter.Value --output text)
CLUSTER_VPC=$(aws eks describe-cluster --name eksworkshop-eksctl | jq -r '.cluster.resourcesVpcConfig.vpcId')
CLUSTER_ENDPOINT=$(aws eks describe-cluster --name eksworkshop-eksctl | jq -r '.cluster.endpoint')
CLUSTER_CA=$(aws eks describe-cluster --name eksworkshop-eksctl | jq -r '.cluster.certificateAuthority.data')
CLUSTER_SG=$(aws eks describe-cluster --name eksworkshop-eksctl --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)
```

We will now create an IAM role that will be used by the nodes in a managed Bottlerocket node group. The has several AWS managed policies attached which allow the calls made by kubelet to AWS APIs.

```bash
EC2_TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": {\"Service\": \"ec2.amazonaws.com\"}, \"Action\": \"sts:AssumeRole\" } ] }"
aws iam create-role --role-name eks-br-node --assume-role-policy-document "$EC2_TRUST"
aws iam attach-role-policy --role-name eks-br-node --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name eks-br-node --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-role-policy --role-name eks-br-node --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam attach-role-policy --role-name eks-br-node --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
ROLE_ARN=$(aws iam get-role --role-name eks-br-node --query Role.Arn --output text) 
```

Let us create an EC2 security group that will allow us to SSH into the Bottlerocket nodes. The public IP of your Cloud 9 environment is added to the inbound rules on this security group. In case the Cloud 9 environment is restarted during this section, you might have to update this inbound rule before trying to SSH into the Bottlerocket nodes.

We will also create an EC2 keypair which will be used to log into the nodes.

```bash
BR_NODE_SG=$(aws ec2 create-security-group --group-name eks-br-node-ssh --description "configure networking for eks br nodes" --vpc-id $CLUSTER_VPC | jq -r ".GroupId")
MYIP=$(curl https://ipinfo.io/ip)/32
aws ec2 authorize-security-group-ingress --group-id $BR_NODE_SG --protocol tcp --port 22 --cidr $MYIP

aws ec2 create-key-pair --key-name eks-br --query "keyMaterial" --output text > eks-br.pem
chmod 400 eks-br.pem
```

We will now start building the EC2 launch template that can be used to create a node group in any EKS cluster in your account. We have to ensure that the [Bottlerocket variant](https://github.com/bottlerocket-os/bottlerocket/tree/develop/variants) picked for the nodes is compatible with the Kubernetes version of your cluster.

```bash
cat <<EoF > user-data.txt
[settings.kubernetes]
cluster-name = "eksworkshop-eksctl"
api-server = "CLUSTER_ENDPOINT"
cluster-certificate = "CLUSTER_CA"
[settings.host-containers.admin]
enabled = true
EoF

base64 -w 0 user-data.txt > user-data-base64.txt
USERDATA=$(cat user-data-base64.txt)
```

Given the commands ran till now provided us the required information to create a launch template, let us run below.

```bash
cat <<EoF > launch-template.json
{
  "ImageId": "$BOTTLEROCKET_AMI",
  "InstanceType": "t3.small",
  "KeyName": "eks-br",
  "SecurityGroupIds": [
    "$CLUSTER_SG",
    "$BR_NODE_SG"
  ],
  "UserData": "$USERDATA"
}
EoF

LAUNCH_TEMPLATE_ID=$(aws ec2 create-launch-template --launch-template-name eks-br-template --launch-template-data file://launch-template.json | jq -r ".LaunchTemplate.LaunchTemplateId")
```

Using the launch template ID and cluster information, we can now prepare a yaml file that can be used to create a new node group in your EKS cluster.

```bash
cat <<EoF > br-managed-ng.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.19"

managedNodeGroups:
  - name: managed-ng-br
    labels: { role: managed-bottlerocket }
    desiredCapacity: 3
    launchTemplate:
      id: ${LAUNCH_TEMPLATE_ID}
    iam:
      instanceRoleARN: arn:aws:iam::122803141216:role/eks-br-node
    subnets:
      - PUBLIC_SUBNET_1
      - PUBLIC_SUBNET_2
      - PUBLIC_SUBNET_3
EoF
```

Open the br-managed-ng.yaml and replace the variables PUBLIC_SUBNET_1, PUBLIC_SUBNET_2 and PUBLIC_SUBNET_3 with the output from below command.

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$CLUSTER_VPC" | jq -r '.Subnets[] | select(.MapPublicIpOnLaunch == true).SubnetId'
```

Once the three subnets obtained from above commands are updated in the yaml file, you are ready to create the managed Bottlerocket node group in your EKS cluster.

```bash
eksctl create nodegroup -f br-managed-ng.yaml
```

Wait until your node group is shown as active in the EKS Console as it might take a few minutes.

![EKS Managed Bottlerocket Node Group](/images/bottlerocket/active_managed_ng.png)

Once it is active, pick any node and obtain it's public IP from the EC2 console to log into it.

```bash
ssh -i "eks-br.pem" ec2-user@<BOTTLEROCKET_NODE_PUBLIC_IP>
```

Below is the welcome message you will observe

{{< output >}}
Welcome to Bottlerocket's admin container!

This container provides access to the Bottlerocket host filesystems (see
/.bottlerocket/rootfs) and contains common tools for inspection and
troubleshooting.  It is based on Amazon Linux 2, and most things are in the
same places you would find them on an AL2 host.

To permit more intrusive troubleshooting, including actions that mutate the
running state of the Bottlerocket host, we provide a tool called "sheltie"
(`sudo sheltie`).  When run, this tool drops you into a root shell in the
Bottlerocket host's root filesystem.
[ec2-user@ip-192-168-79-203 ~]$ 
{{< /output >}}

In the following section, we will compare and contrast Bottlerocket OS with Amazon Linux default configuration.
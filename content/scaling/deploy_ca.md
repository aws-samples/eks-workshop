---
title: "Configure Cluster Autoscaler (CA)"
date: 2018-08-07T08:30:11-07:00
weight: 30
---
Cluster Autoscaler for AWS provides integration with Auto Scaling groups. It enables users to choose from four different options of deployment:

* **One Auto Scaling group** - This is what we will use
* Multiple Auto Scaling groups
* Auto-Discovery
* Master Node setup

### Configure the Cluster Autoscaler (CA)
We have provided a manifest file to deploy the CA. Copy the commands below into your Cloud9 Terminal.

```
mkdir ~/environment/cluster-autoscaler
cd ~/environment/cluster-autoscaler
wget https://eksworkshop.com/scaling/deploy_ca.files/cluster_autoscaler.yml
```

### Configure the ASG
We will need to provide the name of the Autoscaling Group that we want CA to manipulate. Collect the name of the Auto Scaling Group (ASG) containing your worker nodes. Record the name somewhere. We will use this later in the manifest file.

You can find it in the console by following this [link](https://console.aws.amazon.com/ec2/autoscaling/home?#AutoScalingGroups:id=eksctl-eksworkshop-eksctl-nodegroup-0-NodeGroup-SQG8QDVSR73G;view=details;filter=eksworkshop).

![ASG](/images/scaling-asg.png)

Check the box beside the ASG and click `Actions` and `Edit`

Change the following settings:

* Min: **2**
* Max: **8**

![ASG Config](/images/scaling-asg-config.png)

Click `Save`

### Configure the Cluster Autoscaler

Using the file browser on the left, open cluster_autoscaler.yml

Search for `command:` and within this block, replace the placeholder text `<AUTOSCALING GROUP NAME>` with the ASG name that you copied in the previous step. Also, update AWS_REGION value to reflect the region you are using and **Save** the file.

```
command:
  - ./cluster-autoscaler
  - --v=4
  - --stderrthreshold=info
  - --cloud-provider=aws
  - --skip-nodes-with-local-storage=false
  - --nodes=2:8:eksctl-eksworkshop-eksctl-nodegroup-0-NodeGroup-SQG8QDVSR73G
env:
  - name: AWS_REGION
    value: us-east-1
```
This command contains all of the configuration for the Cluster Autoscaler. The primary config is the `--nodes` flag. This specifies the minimum nodes **(2)**, max nodes **(8)** and **ASG Name**.

Although Cluster Autoscaler is the de facto standard for automatic scaling in K8s, it is not part of the main release. We deploy it like any other pod in the kube-system namespace, similar to other management pods.

### Create an IAM Policy
We need to configure an inline policy and add it to the EC2 instance profile of the worker nodes

Collect the Instance Profile and Role NAME from the CloudFormation Stack
```
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
```
```
mkdir ~/environment/asg_policy
cat <<EoF > ~/environment/asg_policy/k8s-asg-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
EoF
aws iam put-role-policy --role-name $ROLE_NAME --policy-name ASG-Policy-For-Worker --policy-document file://~/environment/asg_policy/k8s-asg-policy.json
```

Validate that the policy is attached to the role
```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name ASG-Policy-For-Worker
```

### Deploy the Cluster Autoscaler

```
kubectl apply -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

Watch the logs
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

#### We are now ready to scale our cluster

{{%attachments title="Related files" pattern=".yml"/%}}

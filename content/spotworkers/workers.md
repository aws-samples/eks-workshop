---
title: "Add EC2 Workers - On-Demand and Spot"
date: 2018-08-07T11:05:19-07:00
weight: 10
draft: false
---

We have our EKS Cluster and worker nodes already, but we need some Spot Instances configured as workers. We also need a Node Labeling strategy to identify which instances are Spot and which are on-demand so that we can make more intelligent scheduling decisions. We will use [AWS CloudFormation](https://aws.amazon.com/cloudformation/) to launch new worker
nodes that will connect to the EKS cluster.

CloudFormation is an [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_Code) (IaC) tool which
provides a common language for you to describe and provision all the infrastructure resources in your cloud environment.
CloudFormation allows you to use a simple text file to model and provision, in an automated and secure manner, all the
resources needed for your applications across all regions and accounts.

#### Retrieve the Worker Role name

First, we will need to collect the Role Name that is in use with our EKS worker nodes

```bash
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
echo $ROLE_NAME
```

Copy the Role Name for use as a Parameter in the next step

```text
# Example Output
eksctl-eksworkshop-eksctl-nodegro-NodeInstanceRole-XXXXXXXX
```

#### Launch the CloudFormation Stack

Click the **Launch** button to create the CloudFormation stack in the AWS Management Console.

| Launch template |  |  |
| ------ |:------:|:--------:|
| EKS Workers - Spot and On Demand |  {{% cf-launch "amazon-eks-nodegroup-with-spot.yml?stackName=eksworkshop-nodegroup-0" %}} | {{% cf-download "amazon-eks-nodegroup-with-spot.yml" %}}  |

{{% notice info %}}
Confirm the region is correct based on where you've deployed your cluster.
{{% /notice %}}
Once the console is open you will need to configure the missing parameters. Use the table below for guidance.

| Parameter | Value |
|-----------|-------|
| Stack Name: | eksworkshop-nodegroup-0 |
| Cluster Name: | eksworkshop-eksctl (or whatever you named your cluster) |
|ClusterControlPlaneSecurityGroup: | Select from the dropdown. It will contain your cluster name and the words 'ClusterControlPlane' |
|NodeInstanceRole: | Use the same role name that is used with to the other EKS worker nodes. (e.g. eksctl-eksworkshop-eksctl-nodegro-NodeInstanceRole-XXXXX)
|NodeImageId: | Visit this [**link**](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) and select the non-GPU image for eu-west-1 - **Check for empty spaces in copy/paste**|
|KeyName: | SSH Key Pair created earlier or any valid key will work |
|VpcId: | Select your workshop VPC from the dropdown |
|Subnets: | Select the subnets for your workshop VPC from the dropdown |
|OnDemandBootstrapArguments: | See Challenge Below |
|SpotBootstrapArguments: | See Challenge Below |

The EKS Bootstrap.sh script is packaged into the EKS Optimized AMI that we are using, and only requires a single input: the EKS Cluster name. The bootstrap script supports setting any `kubelet-extra-args` at runtime. You will need to configure `node-labels` so that kubernetes knows what type of nodes we have provisioned. Set the `lifecycle` for the nodes as `OnDemand` or `Ec2Spot`. Check out this [**link**](https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/) for more information

#### Challenge:
**What do we need to use for our Bootstrap Arguments?**
{{% expand "Expand here to see the solution"%}}

```text
--kubelet-extra-args --node-labels=lifecycle=OnDemand
```

```text
--kubelet-extra-args --node-labels=lifecycle=Ec2Spot
```
{{%/expand%}}

You can leave the rest of the default parameters as is and continue through the remaining CloudFormation screens. Check the box next to **I acknowledge that AWS CloudFormation might create IAM resources** and click **Create**

The creation of the workers will take about 3 minutes. This is a script that will let you know when the CloudFormation stack is complete:

```
until [[ `aws cloudformation describe-stacks --stack-name "eksworkshop-nodegroup-0" --query "Stacks[0].[StackStatus]" --output text` == "CREATE_COMPLETE" ]]; do  echo "The stack is NOT in a state of CREATE_COMPLETE at `date`";   sleep 30; done && echo "The Stack is built at `date` - Please proceed"
```

#### Confirm the Nodes

Confirm that the new nodes joined the cluster correctly. You should see 2-3 more nodes added to the cluster.

```bash
kubectl get nodes
```

You can use the node-labels to identify the lifecycle of the nodes
```bash
kubectl get nodes --show-labels --selector=lifecycle=Ec2Spot
```
```bash
kubectl get nodes --show-labels --selector=lifecycle=OnDemand
```
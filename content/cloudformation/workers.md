---
title: "Add EC2 Workers - On-Demand and Spot"
date: 2018-08-07T11:05:19-07:00
weight: 60
draft: false
---

Now that your VPC and Kubernetes control plane are created, you can launch and
configure your worker nodes. We will now use CloudFormation to launch worker
nodes that will connect to the EKS cluster:

First, make export our network information
```
export SECURITY_GROUP=$(aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue" --output text)
export SUBNET_IDS=$( aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue" --output text)
export VPC_ID=$(aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" --output text)
```

Let’s confirm the variables are now set in our environment:
```
echo VPC_ID=${VPC_ID}
echo SECURITY_GROUP=${SECURITY_GROUP}
echo SUBNET_IDS=${SUBNET_IDS}
```
Now we are going to create the worker nodes using [AWS CloudFormation](https://aws.amazon.com/cloudformation/).

CloudFormation is an [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_Code) (IaC) tool which
provides a common language for you to describe and provision all the infrastructure resources in your cloud environment.
CloudFormation allows you to use a simple text file to model and provision, in an automated and secure manner, all the
resources needed for your applications across all regions and accounts.

Click the **Launch** button to create the CloudFormation stack in the AWS Management Console.

| Launch template |  |  |
| ------ |:------:|:--------:|
| EKS Workers - Spot and On Demand |  {{% cf-launch "amazon-eks-nodegroup-with-spot.yml?stackName=eksworkshop-nodegroup-0" %}} | {{% cf-download "amazon-eks-nodegroup-with-spot.yml" %}}  |

{{% notice info %}}
Confirm the region is correct **(eu-west-1)**.
{{% /notice %}}
Once the console is open you will need to configure the missing parameters. Use the table below for guidance.

| Parameter | Value |
|-----------|-------|
| Stack Name: | eksworkshop-nodegroup-0 |
| Cluster Name: | eksworkshop (or whatever you named your cluster) |
|ClusterControlPlaneSecurityGroup: | Select from the dropdown. It will contain your cluster name and ControlPlane |
|NodeImageId: | Visit this [**link**](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) and select the non-GPU image for eu-west-1 |
|KeyName: | SSH Key Pair created earlier |
|VpcId: | Select your workshop VPC from the dropdown |
|Subnets: | Select the subnets for your workshop VPC from the dropdown |
|OnDemandBootstrapArguments: | See Below |
|SpotBootstrapArguments: | See Below |

The EKS Bootstrap.sh script is packaged into the EKS Optimized AMI that we are using, and only requires a single input: the EKS Cluster name. The bootstrap script supports setting any `kubelet-extra-args` at runtime. You will need to configure `node-labels` so that kubernetes knows what type of nodes we have provisioned. Set the `lifecycle` for the nodes as `OnDemand` or `Ec2Spot`

Check out this [**link**](https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/) for more information

{{% expand "ONLY If you get stuck..."%}}
```
--kubelet-extra-args --node-labels=lifecycle=OnDemand
```
```
--kubelet-extra-args --node-labels=lifecycle=Ec2Spot
```
{{%/expand%}}

You can leave the rest of the default parameters as is and continue through the remaining CloudFormation screens. Check the box next to **I acknowledge that AWS CloudFormation might create IAM resources** and click **Create** 

The creation of the workers will take about 3 minutes. This is a script that will let you know when the CloudFormation stack is complete:

```
until [[ `aws cloudformation describe-stacks --stack-name "eksworkshop-nodegroup-0" --query "Stacks[0].[StackStatus]" --output text` == "CREATE_COMPLETE" ]]; do  echo "The stack is NOT in a state of CREATE_COMPLETE at `date`";   sleep 30; done && echo "The Stack is built at `date` - Please proceed"
```
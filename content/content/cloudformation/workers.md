---
title: "Add EC2 Workers - On-Demand and Spot"
date: 2018-08-07T11:05:19-07:00
weight: 60
draft: false
---

### TODO: Code here to highlight the spot node labels Note: Create atleast 2 separate ASG's like in blog.


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
| EKS Worker Nodes |  {{% cf-launch "amazon-eks-nodegroup-with-spot.yml?stackName=eksworkshop-nodegroup-0" %}} | {{% cf-download "amazon-eks-nodegroup-with-spot.yml" %}|

Once the console is open you will need to configure the missing parameters.


{{% notice info %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}
This is a script that will let you know when the CloudFormation stack is complete:
```
until [[ `aws cloudformation describe-stacks --stack-name "eksworkshop-nodegroup-0" --query "Stacks[0].[StackStatus]" --output text` == "CREATE_COMPLETE" ]]; do  echo "The stack is NOT in a state of CREATE_COMPLETE at `date`";   sleep 30; done && echo "The Stack is built at `date` - Please proceed"
```

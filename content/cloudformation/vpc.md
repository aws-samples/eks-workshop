---
title: "Create the VPC"
date: 2018-08-07T09:15:38-07:00
weight: 30
draft: false
---
EKS suggests launching a single EKS Cluster into a VPC. To make that easy, EKS
provides a CloudFormation template that we can use:
{{% notice tip %}}
The latest version of the CloudFormation template can be found here: https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html
{{% /notice %}}
```
aws cloudformation create-stack --stack-name "eksworkshop-vpc" --template-url "https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-08-30/amazon-eks-vpc-sample.yaml"
```
{{% notice info %}}
The creation of the EKS VPC Stack will take about 2 minutes.
{{% /notice %}}

This is a script that will let you know when the CloudFormation stack is complete:
```bash
until [[ `aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].[StackStatus]" --output text` == "CREATE_COMPLETE" ]]; do  echo "The stack is NOT in a state of CREATE_COMPLETE at `date`";   sleep 30; done && echo "The Stack is built at `date` - Please proceed"
```

Now that you have your VPC ready, you can Launch your EKS cluster.

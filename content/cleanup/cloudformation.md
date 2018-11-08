---
title: "Cleanup the CloudFormation Cluster"
date: 2018-08-07T12:37:34-07:00
weight: 30
draft: false
---
To clean up the resources in your AWS account created by this workshop.
Run the following commands:

Remove the Worker nodes from EKS:
```
aws cloudformation delete-stack --stack-name "eksworkshop-nodegroup0"
```
Delete the EKS Cluster:
```
aws eks delete-cluster --name "eksworkshop"
```
{{% notice info %}}
Confirm the Cluster is deleted before removing Cluster VPC:
{{% /notice %}}
```
aws eks describe-cluster --name eksworkshop --query "cluster.status"
```
Remove the Cluster VPC:
```
aws cloudformation delete-stack --stack-name "eksworkshop-vpc"
```
Detach IAM Policies and delete the role created for the EKS cluster:
```
aws iam detach-role-policy --role-name "EKSServiceRole" --policy-arn "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
aws iam detach-role-policy --role-name "EKSServiceRole" --policy-arn "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
aws iam delete-role --role-name "EKSServiceRole"
```

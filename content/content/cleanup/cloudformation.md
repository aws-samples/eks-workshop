---
title: "Cleanup the CloudFormation Cluster"
date: 2018-08-07T12:37:34-07:00
weight: 10
draft: true
---
To clean up the resources in your AWS account created by this workshop.
Run the following commands:

Remove the Worker nodes from EKS:
```
aws cloudformation delete-stack --stack-name "eksworkshop-cf-worker-nodes"
```
Delete the EKS Cluster:
```
aws eks delete-cluster --name "eksworkshop-cf"
```
Confirm the Cluster is deleted before removing Cluster VPC:
```
aws eks describe-cluster --name eksworkshop-cf --query "cluster.status"
```
Remove the Cluster VPC:
```
aws cloudformation delete-stack --stack-name "eksworkshop-cf"
```
Detach IAM Policies from Role:
```
aws iam detach-role-policy --role-name "eks-service-role-workshop" --policy-arn "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
aws iam detach-role-policy --role-name "eks-service-role-workshop" --policy-arn "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
```
Remove the IAM Role created for the EKS cluster:
```
aws iam delete-role --role-name "eks-service-role-workshop"
```

---
title: "Attach IAM Policy to the EKS Service Role"
date: 2018-08-07T08:51:18-07:00
weight: 20
draft: true
---

We have now created the IAM Role for the EKS Service. At the moment, it still
has no permissions and can't do anything. We can confirm that with this command:
```
aws iam list-attached-role-policies --role-name "eks-service-role-workshop"
```


We need to attach IAM Policies to
the role to grant it permissions.

EKS has pre-created two policies that we can use:
```
aws iam attach-role-policy --role-name "eks-service-role-workshop" --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

aws iam attach-role-policy --role-name "eks-service-role-workshop" --policy-arn arn:aws:iam::aws:policy/AmazonEKSServicePolicy
```
{{% notice info %}}
Expect to see no output from these two commands. Only **_failure_** of the commands will produce an output.
{{% /notice %}}

We can confirm the policies were now attached successfully:
```
aws iam list-attached-role-policies --role-name "eks-service-role-workshop"
```
You now have the IAM Role and Permissions required to Launch an EKS cluster.

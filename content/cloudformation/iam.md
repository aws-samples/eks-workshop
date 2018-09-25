---
title: "Create the EKS Service Role"
date: 2018-08-07T08:30:11-07:00
weight: 10
draft: true
---

A service-linked role is a unique type of IAM role that is linked directly to
an AWS service. Service-linked roles are predefined by the service and include
all the permissions that the service requires to call other AWS services on your behalf.

First we need to create the EKS Service Role, an IAM Role that EKS will use to manage your EKS Cluster:
```
cd ${HOME}/environment/howto-launch-eks-workshop/

aws iam create-role --role-name "eks-service-role-workshop" \
--assume-role-policy-document file://assets/eks-iam-trust-policy.json \
--description "EKS Service role created through the HOWTO workshop"
```

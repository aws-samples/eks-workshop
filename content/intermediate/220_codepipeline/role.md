---
title: "Create IAM Role"
date: 2018-10-087T08:30:11-07:00
weight: 10
draft: false
---

In an AWS CodePipeline, we are going to use AWS CodeBuild to deploy a sample Kubernetes service.
This requires an [AWS Identity and Access Management](https://aws.amazon.com/iam/) (IAM) role capable of interacting
with the EKS cluster.

In this step, we are going to create an IAM role and add an inline policy that we will use in the CodeBuild stage
to interact with the EKS cluster via kubectl.

Create the role:

```
cd ~/environment

TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"arn:aws:iam::${ACCOUNT_ID}:root\" }, \"Action\": \"sts:AssumeRole\" } ] }"

echo '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": "eks:Describe*", "Resource": "*" } ] }' > /tmp/iam-role-policy

aws iam create-role --role-name EksWorkshopCodeBuildKubectlRole --assume-role-policy-document "$TRUST" --output text --query 'Role.Arn'

aws iam put-role-policy --role-name EksWorkshopCodeBuildKubectlRole --policy-name eks-describe --policy-document file:///tmp/iam-role-policy
```

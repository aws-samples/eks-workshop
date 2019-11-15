---
title: "Creating an IAM Role for Service Account"
date: 2018-11-13T16:36:24+09:00
weight: 30
draft: false
---

### To create an IAM role for your service accounts with eksctl

You must create an IAM policy that specifies the permissions that you would like the containers in your pods to have. In this workshop we will use AWS managed policy named "**AmazonS3ReadOnlyAccess**" which allow get and list for all S3 resources.

You must also create a role for your service accounts to use before you associate it with a service account. Then you can then attach a specific IAM policy to the role that gives the containers in your pods the permissions you desire.

* Get ARN for AmazonS3ReadOnlyAccess

```
aws iam list-policies --query 'Policies[?PolicyName==`AmazonS3ReadOnlyAccess`].Arn'
```

> "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

* Create an IAM role for your service accounts

```
eksctl create iamserviceaccount --name iam-test --namespace default --cluster eksworkshop-eksctl --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --approve --override-existing-serviceaccounts
```

> [ℹ]  using region {AWS_REGION}<br>[ℹ]  1 iamserviceaccount (default/iam-test) was included (based on the include/exclude rules)<br>[!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set<br>[ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "default/iam-test", create serviceaccount "default/iam-test" } }<br>[ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-default-iam-test"<br>[ℹ]  deploying stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-default-iam-test"<br>[ℹ]  created serviceaccount "default/iam-test"


{{% notice info %}}
If you go to the [CloudFormation in IAM Console](https://console.aws.amazon.com/cloudformation/), you will find the stack "**eksctl-eksworkshop-eksctl-addon-iamserviceaccount-default-iam-test**" has been created a role for your service account
{{% /notice %}}

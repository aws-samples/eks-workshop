---
title: "Creating an IAM Role for Service Account"
date: 2021-07-20T00:00:00-03:00
weight: 30
draft: false
---

You will create an IAM policy that specifies the permissions that you would like the containers in your pods to have.

In this workshop we will use the AWS managed policy named "**AmazonS3ReadOnlyAccess**" which allow `get` and `list` for all your S3 buckets.

Let's start by finding the ARN for the "**AmazonS3ReadOnlyAccess**" policy

```bash
aws iam list-policies --query 'Policies[?PolicyName==`AmazonS3ReadOnlyAccess`].Arn'
```

{{< output >}}
"arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
{{< /output >}}

Now you will create a IAM role bound to a service account with read-only access to S3

```bash
eksctl create iamserviceaccount \
    --name iam-test \
    --namespace default \
    --cluster eksworkshop-eksctl \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
    --approve \
    --override-existing-serviceaccounts
```

{{< output >}}
2021-07-21 10:31:14 [ℹ]  eksctl version 0.57.0
2021-07-21 10:31:14 [ℹ]  using region us-east-1
2021-07-21 10:31:17 [ℹ]  1 iamserviceaccount (default/iam-test) was included (based on the include/exclude rules)
2021-07-21 10:31:17 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2021-07-21 10:31:17 [ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "default/iam-test", create serviceaccount "default/iam-test" } }
2021-07-21 10:31:17 [ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-default-iam-test"
2021-07-21 10:31:17 [ℹ]  deploying stack "eksctl-sandbox-addon-iamserviceaccount-default-iam-test"
2021-07-21 10:31:17 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-default-iam-test"
2021-07-21 10:31:53 [ℹ]  created serviceaccount "default/iam-test"
{{< /output >}}

{{% notice info %}}
If you go to the [CloudFormation in IAM Console](https://console.aws.amazon.com/cloudformation/), you will find that the stack "**eksctl-eksworkshop-eksctl-addon-iamserviceaccount-default-iam-test**" has created a role for your service account.
{{% /notice %}}

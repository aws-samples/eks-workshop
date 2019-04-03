---
title: "Configure Artifact Repository"
date: 2018-11-18T00:00:00-05:00
weight: 50
draft: false
---

### Configure Artifact Repository

Argo uses an artifact repository to pass data between jobs in a workflow, known as artifacts. Amazon S3 can be used as an artifact repository.

Let's create a S3 bucket using the AWS CLI.

{{< tabs name="Create S3 Bucket" >}}
{{{< tab name="Workshop at AWS event" >}}
This S3 bucket has been created for you.<br>

You can proceed with the next step.
{{< /tab >}}
{{< tab name="Workshop in your own account" codelang="bash" >}}
aws s3 mb s3://batch-artifact-repository-${ACCOUNT_ID}/
{{< /tab >}}}
{{< /tabs >}}

Next, edit the workflow-controller ConfigMap to use the S3 bucket.

```bash
kubectl edit -n argo configmap/workflow-controller-configmap
```

Add the following lines to the end of the ConfigMap, substituting your Account ID for `{{ACCOUNT_ID}}`:

```
data:
  config: |
    artifactRepository:
      s3:
        bucket: batch-artifact-repository-{{ACCOUNT_ID}}
        endpoint: s3.amazonaws.com
```

### Create an IAM Policy
In order for Argo to read from/write to the S3 bucket, we need to configure an inline policy and add it to the EC2 instance profile of the worker nodes.

First, we will need to ensure the Role Name our workers use is set in our environment:

```bash
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set
```

If you receive an error or empty response, expand the steps below to export.

{{%expand "Expand here if you need to export the Role Name" %}}
If `ROLE_NAME` is not set, please review: [/eksctl/test/](/eksctl/test/)
{{% /expand %}}

```text
# Example Output
ROLE_NAME is eks-workshop-nodegroup
```

Create and policy and attach to the worker node role.

{{< tabs name="Create IAM policy and attach to the worker node role." >}}
{{{< tab name="Workshop at AWS event" >}}
This IAM policy has been created for you  and has been attached to the correct role.<br>

You can proceed with the next step.
{{< /tab >}}
{{< tab name="Workshop in your own account" codelang="bash" >}}
mkdir ~/environment/batch_policy
cat <<EoF > ~/environment/batch_policy/k8s-s3-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::batch-artifact-repository-${ACCOUNT_ID}",
        "arn:aws:s3:::batch-artifact-repository-${ACCOUNT_ID}/*"
      ]
    }
  ]
}
EoF
aws iam put-role-policy --role-name $ROLE_NAME --policy-name S3-Policy-For-Worker --policy-document file://~/environment/batch_policy/k8s-s3-policy.json
{{< /tab >}}}
{{< /tabs >}}



Validate that the policy is attached to the role
```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name S3-Policy-For-Worker
```

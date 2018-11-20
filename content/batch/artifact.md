---
title: "Configure Artifact Repository"
date: 2018-11-18T00:00:00-05:00
weight: 50
draft: false
---

### Configure Artifact Repository

Argo uses an artifact repository to pass data between jobs in a workflow, known as artifacts. Amazon S3 can be used as an artifact repository.

Let's create a S3 bucket using the AWS CLI.

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
aws s3 mb s3://batch-artifact-repository-${ACCOUNT_ID}/
```

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

Collect the Instance Profile, Role name, and Account ID from the CloudFormation Stack.
```
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
```

Create and policy and attach to the worker node role.

```
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
```

Validate that the policy is attached to the role
```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name S3-Policy-For-Worker
```
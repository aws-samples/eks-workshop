---
title: "Cleanup"
date: 2018-11-18T00:00:00-05:00
weight: 90
draft: false
---

### Cleanup

#### Delete all workflows

```bash
argo delete --all
```

#### Remove Artifact Repository Bucket

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
aws s3 rb s3://batch-artifact-repository-${ACCOUNT_ID}/ --force
```

#### Remove permissions for Artifact Repository Bucket
```bash
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

aws iam delete-role-policy --role-name $ROLE_NAME --policy-name S3-Policy-For-Worker
```

#### Undeploy Argo

```bash
kubectl delete -n argo -f https://raw.githubusercontent.com/argoproj/argo/v2.2.1/manifests/install.yaml
kubectl delete ns argo
```

#### Cleanup Kubernetes Job

```bash
kubectl delete job/whalesay
```

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
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

```
aws s3 rb s3://batch-artifact-repository-${ACCOUNT_ID}/ --force
```

#### Undeploy Argo

```bash
kubectl delete -n argo -f https://raw.githubusercontent.com/argoproj/argo/v2.2.1/manifests/install.yaml
kubectl delete namespace argo
```

#### Cleanup Kubernetes Job

```bash
kubectl delete job/whalesay
```

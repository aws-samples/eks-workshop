---
title: "Cleanup"
date: 2018-11-18T00:00:00-05:00
weight: 90
draft: false
---

### Cleanup

#### Delete all workflows

```bash
argo -n argo delete --all
```

#### Remove Artifact Repository Bucket

```bash
aws s3 rb s3://batch-artifact-repository-${ACCOUNT_ID}/ --force
```

#### Undeploy Argo

```bash
kubectl delete -n argo -f https://raw.githubusercontent.com/argoproj/argo/${ARGO_VERSION}/manifests/install.yaml

kubectl delete namespace argo
```

#### Cleanup Kubernetes Job

```bash
kubectl delete job/whalesay
```

#### delete the inline policy

```bash
 aws iam delete-role-policy --role-name $ROLE_NAME --policy-name S3-Policy-For-Worker
 ```

#### delete the folder and all the files in it

```bash
rm -rf ~/environment/batch_policy
```

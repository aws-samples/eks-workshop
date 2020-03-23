---
title: "Cleanup"
weight: 50
draft: false
---

Cleanup staging namepspace

```
kubectl delete namespace staging
kubectl delete storageclass staging
```

Cleanup velero namespace

```
kubectl delete namespace velero
```

Delete S3 Bucket
```
aws s3 rb s3://$BUCKET --force
```
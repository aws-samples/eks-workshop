---
title: "Cleanup"
date: 2019-03-20T13:59:44+01:00
weight: 60
draft: false
---

To cleanup, follow the below steps.

To remove sample application

```
kubectl delete -f iam-pod.yaml
```

To remove IAM role and Service Account stack from cloudformation

```
eksctl delete iamserviceaccount --name iam-test --namespace default --cluster eksworkshop-eksctl
```

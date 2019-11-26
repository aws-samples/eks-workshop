---
title: "Deploy Crystal Backend API"
date: 2018-09-18T17:40:03-05:00
weight: 20
---

Let’s bring up the Crystal Backend API!

Copy/Paste the following commands into your Cloud9 workspace:

```
cd ~/environment/ecsdemo-crystal
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

We can watch the progress by looking at the deployment status:
```
kubectl get deployment ecsdemo-crystal
```

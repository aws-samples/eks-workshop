---
title: "Deploy NodeJS Backend API"
date: 2018-09-18T17:39:30-05:00
weight: 10
---

Let’s bring up the NodeJS Backend API!

Copy/Paste the following commands into your Cloud9 workspace:

```
cd ~/environment/ecsdemo-nodejs
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

We can watch the progress by looking at the deployment status:
```
kubectl get deployment ecsdemo-nodejs
```

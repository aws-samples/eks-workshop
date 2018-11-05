---
title: "Deploy Frontend Service"
date: 2018-09-18T17:40:09-05:00
weight: 30
---
Let’s bring up the Ruby Frontend!

Copy/Paste the following commands into your Cloud9 workspace:

```
cd ~/environment/ecsdemo-frontend
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

We can watch the progress by looking at the deployment status:
```
kubectl get deployment ecsdemo-frontend
```

We can check all pods (including the frontend) deployed on Spot Instances with this command:
```
 for n in $(kubectl get nodes -l lifecycle=Ec2Spot --no-headers | cut -d " " -f1); do kubectl get pods --all-namespaces  --no-headers --field-selector spec.nodeName=${n} ; done
```



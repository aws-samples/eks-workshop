---
title: "Cleanup the applications"
date: 2018-08-07T13:37:53-07:00
weight: 90
---

To delete the resources created by the applications, we should delete the application
deployments:

Undeploy the applications:
```
cd ~/environment/ecsdemo-frontend
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

cd ~/environment/ecsdemo-crystal
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

cd ~/environment/ecsdemo-nodejs
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml
```

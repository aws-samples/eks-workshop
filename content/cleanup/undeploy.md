---
title: "Undeploy the Applications"
date: 2018-08-07T13:37:53-07:00
weight: 20
---

To delete the resources created by the applications, we should delete the application
deployments and kubernetes dashboard:

Undeploy the Applications:
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

kubectl delete deployment/nginx-to-scaleout
kubectl delete -f ~/environment/spot/spot-interrupt-handler-example.yml
kubectl delete -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

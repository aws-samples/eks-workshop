---
title: "Undeploy the applications"
date: 2018-08-07T13:37:53-07:00
weight: 20
---

To delete the resources created by the applications, we should delete the application
deployments and kubernetes dashboard.

Note that if you followed the cleanup section of the modules, some of the commands below might fail because there is nothing to delete and its ok.

Undeploy the applications:

```bash
cd ~/environment/ecsdemo-frontend
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

cd ~/environment/ecsdemo-crystal
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

cd ~/environment/ecsdemo-nodejs
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

export DASHBOARD_VERSION="v2.0.0"

kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/src/deploy/recommended/kubernetes-dashboard.yaml
```

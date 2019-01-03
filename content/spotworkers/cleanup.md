---
title: "Cleanup"
weight: 50
draft: false
---
Cleanup our Microservices deployment

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
```

Cleanup the Spot Handler Daemonset

```bash
kubectl delete -f ~/environment/spot/spot-interrupt-handler-example.yml
```

To clean up the worker created by this module, run the following commands:

Remove the Worker nodes from EKS:

```bash
aws cloudformation delete-stack --stack-name "eksworkshop-spot-workers"
```

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

To delete the label and the Node Group created by this module, run the following commands

```bash
kubectl label nodes --all lifecycle-

eksctl delete nodegroup --cluster=eksworkshop-eksctl --region=${AWS_REGION} --name=ng-spot
```

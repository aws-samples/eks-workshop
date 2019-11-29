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
kubectl delete -k https://github.com/aws/aws-node-termination-handler/config/overlays/spot-node-selector?ref=master
```

To delete the label and the Node Group created  by this module, run the following commands

```bash
 kubectl label nodes --all lifecycle-

eksctl delete nodegroup -f  ~/environment/eks-workshop-ng-spot.yaml --approve
```

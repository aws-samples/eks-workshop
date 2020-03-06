---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 16
draft: false
---

### Cleaning up
To delete the resources used in this chapter: 
```
cd ~/environment/fargate
kubectl delete -f nginx-ingress.yaml
kubectl delete -f alb-ingress-controller.yaml 
kubectl delete -f rbac-role.yaml 
kubectl delete -f nginx-deployment.yaml 
eksctl delete fargateprofile --name applications --cluster eksworkshop-eksctl
```

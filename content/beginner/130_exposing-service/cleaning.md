---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---

### Cleaning up
To delete the resources used in this chapter: 
```
kubectl delete -f ~/environment/run-my-nginx.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.0.0/docs/examples/2048/2048-deployment.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.0.0/docs/examples/2048/2048-service.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.0.0/docs/examples/2048/2048-ingress.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.0.0/docs/examples/2048/2048-namespace.yaml
kubectl delete -f ~/environment/alb-ingress-controller.yaml
```

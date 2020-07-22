---
title: "Cleanup Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 60
hidden: true
---

## Cleaning up HPA, CA, and the Microservice
```
kubectl delete hpa monte-carlo-pi-service
kubectl delete -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
kubectl delete -f monte-carlo-pi-service.yml
```


## Removing eks Spot nodes from the cluster

```
eksctl delete nodegroup -f spot_nodegroups.yml --approve
```

---
title: "Cleanup Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

```
kubectl delete -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
kubectl delete -f ~/environment/cluster-autoscaler/nginx.yaml
kubectl delete hpa,svc php-apache
kubectl delete deployment php-apache load-generator
rm -rf ~/environment/cluster-autoscaler
```

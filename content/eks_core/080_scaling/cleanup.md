---
title: "Cleanup Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

```sh
aws iam delete-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-name ASG-Policy-For-Worker

kubectl delete -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
kubectl delete -f ~/environment/cluster-autoscaler/nginx.yaml
kubectl delete hpa,svc php-apache
kubectl delete deployment php-apache load-generator
rm -rf ~/environment/cluster-autoscaler

helm -n metrics uninstall metrics-server

kubectl delete ns metrics
```

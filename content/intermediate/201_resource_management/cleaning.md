---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 16
draft: false
---

Ensure all the resources created in this module are cleaned up.
```
# Basic Pod CPU and Memory Management
kubectl delete pod basic-request-pod
kubectl delete pod basic-limit-memory-pod
kubectl delete pod basic-limit-cpu-pod
kubectl delete pod basic-restricted-pod

# Advanced Pod CPU and Memory Management
kubectl delete namespace low-usage
kubectl delete namespace high-usage
kubectl delete namespace unrestricted-usage

# Resource Quotas
kubectl delete namespace red
kubectl delete namespace blue

# Pod Priority and Preemption
kubectl delete deployment high-nginx-deployment
kubectl delete deployment nginx-deployment
kubectl delete priorityclass high-priority
kubectl delete priorityclass low-priority

# Prerequisites 
rm  -r ~/environment/resource-management/
helm uninstall metrics-server --namespace metrics
kubectl delete namespace metrics-server
```




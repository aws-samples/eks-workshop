---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 13
draft: false
---

### Cleaning up
To delete the resources used in this chapter: 
```
kubectl delete -f ~/environment/pod-nginx.yaml 
kubectl delete -f ~/environment/pod-with-node-affinity.yaml
kubectl delete -f ~/environment/redis-with-node-affinity.yaml
kubectl delete -f ~/environment/web-with-node-affinity.yaml
```

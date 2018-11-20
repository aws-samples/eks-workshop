---
title: "Cleanup"
chapter: true
weight: 25
---

# Cleanup

```
kubectl delete -f ~/environment/healthchecks/liveness-app.yaml
kubectl delete -f ~/environment/healthchecks/readiness-service.yaml
```

Liveness Probe used HTTP request and Readiness Probe executed a command to check health of a pod. Same can be accomplished using a TCP request as described in the [documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/).

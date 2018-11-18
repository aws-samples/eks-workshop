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

Both the examples in this section use HTTP request to check health of a pod. Same can be accomplished using a TCP request or executing a command as described in the [documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/).

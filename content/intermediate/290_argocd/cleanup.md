---
title: "Cleanup"
weight: 50
draft: false
---

Congratulations on completing the Continuous Deployment with ArgoCD module.

This module is not used in subsequent steps, so you can remove the resources now, or at the end of the workshop:
```
argocd app delete ecsdemo-nodejs
watch argocd app get ecsdemo-nodejs
```

Wait until all ressources are cleared with this message:
```
FATA[0000] rpc error: code = NotFound desc = applications.argoproj.io "ecsdemo-nodejs" not found 
```

And then delete ArgoCD from your cluster:

```
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
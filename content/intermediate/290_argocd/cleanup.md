---
title: "Cleanup"
weight: 50
draft: false
---

Congratulations on completing the Continuous Deployment with ArgoCD module.

This module is not used in subsequent steps, so you can remove the resources now, or at the end of the workshop:
```
argocd app delete ecsdemo-nodejs -y
watch argocd app get ecsdemo-nodejs
```

Wait until all ressources are cleared with this message:
```
FATA[0000] rpc error: code = NotFound desc = applications.argoproj.io "ecsdemo-nodejs" not found 
```

And then delete ArgoCD from your cluster:
```
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
```

Delete namespaces created for this chapter:
```
kubectl delete ns argocd
kubectl delete ns ecsdemo-nodejs
```

You may also delete the cloned repository `ecsdemo-nodejs` within your GitHub account.

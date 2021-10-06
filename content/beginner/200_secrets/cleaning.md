---
title: "Clean Up"
date: 2021-07-15T00:00:00-03:00
weight: 16
draft: false
---

Delete all the resources created in this module.
```
cd ~/environment/secrets
kubectl delete Secret --all -n octank
kubectl delete SealedSecret --all -n octank
kubectl delete pod --all -n octank
kubectl delete -f controller.yaml
kubectl delete namespace octank
```




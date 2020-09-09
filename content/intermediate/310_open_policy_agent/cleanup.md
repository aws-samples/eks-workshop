---
title: "Clean up"
weight: 30
draft: false
---

#### Clean up steps

```
kubectl delete namespace opa
kubectl delete -f webhook-configuration.yaml
kubectl delete -f admission-controller.yaml
cd ..
rm -rf opa
```

---
title: "Clean Up"
date: 2021-05-26T00:00:00-03:00
weight: 40
draft: false
---

### Cleaning up

To delete the resources used in this chapter:

```bash
kubectl delete -f ~/environment/bottlerocket-nginx.yaml

kubectl delete namespace bottlerocket-nginx

eksctl delete nodegroup -f eksworkshop_bottlerocket.yaml --approve
```

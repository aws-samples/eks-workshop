---
title: "Cleanup"
date: 2020-07-28T07:51:45-04:00
draft: false
weight: 540
---

```bash
kubectl delete -f https://www.eksworkshop.comadvanced/500_windows/app_deploy/deploy.files/windows_server_iis.yaml

kubectl delete namespace windows

eksctl delete nodegroup \
    -f ~/environment/windows/windows_nodes.yaml \
    --approve
    --wait
```

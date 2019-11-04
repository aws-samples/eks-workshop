---
title: "Cleanup"
date: 2019-10-25T15:43:24-04:00
weight: 90
draft: false
---

### Uninstall Kubeflow

Run these commands to uninstall Kubeflow from your EKS cluster
```
cd ${KF_DIR}
kfctl delete -V -f ${CONFIG_FILE}
```

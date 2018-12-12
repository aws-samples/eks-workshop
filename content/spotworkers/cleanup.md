---
title: "Cleanup"
weight: 50
draft: false
---
To clean up the worker created by this module, run the following commands:

Remove the Worker nodes from EKS:

```bash
aws cloudformation delete-stack --stack-name "eksworkshop-nodegroup0"
```

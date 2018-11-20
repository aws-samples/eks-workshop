---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 5
---
Clean up the demo by deleting the namespaces:

```
kubectl delete ns client stars management-ui
```
Uninstall Calico:

```
kubectl delete -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.2/calico.yaml
```

---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 5
---
Clean up the demo by deleting the namespaces:

```
kubectl delete namespace client stars management-ui
```

<!---
We will not uninstall Calico because of issues related IpTables. There is a hack on how to cleanup but this doesn't work on AWS platform
https://github.com/projectcalico/calico/blob/master/hack/remove-calico-policy/remove-policy.md

Uninstall Calico:

```
kubectl delete -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.2/calico.yaml
```
-->

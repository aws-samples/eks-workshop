---
title: "Cleanup"
date: 2020-07-28T07:51:45-04:00
draft: false
weight: 350
---

```bash
calicoctl delete -f - < ~/environment/windows/deny_icmp.yaml
unalias calicoctl
kubectl delete -f https://docs.projectcalico.org/archive/v3.15/manifests/calicoctl.yaml
kubectl delete -f ~/environment/windows/sample-deployments.yaml
kubectl delete -f ~/environment/windows/user-rolebinding.yaml
kubectl delete -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.6/calico.yaml
kubectl delete -f ~/environment/windows/windows_server_iis.yaml

kubectl delete namespace windows

eksctl delete nodegroup \
    -f ~/environment/windows/windows_nodes.yaml \
    --approve \
    --wait

rm -rf ~/environment/windows/
```

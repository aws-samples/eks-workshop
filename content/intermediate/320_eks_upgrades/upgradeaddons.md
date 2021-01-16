---
title: "Upgrade EKS Core Add-ons"
weight: 323
---

When you provision an EKS cluster you get three add-ons that run on top of the cluster and that are required for it to function properly:
- kubeproxy
- CoreDNS
- aws-node (AWS CNI or Network Plugin)

Looking at the the [upgrade documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html#w665aac14c15b5c17) for our 1.17 to 1.18 upgrade we see that we'll need to upgrade the kubeproxy and CoreDNS. In addition to performing these steps manually with kubectl as documented there you'll find that eksctl can do it for you as well.

Since we are using eksctl in the workshop we'll run the two necessary commands for it to do these updates for us:
```bash
eksctl utils update-kube-proxy --cluster=eksworkshop-eksctl --approve
```

and then

```bash
eksctl utils update-coredns --cluster=eksworkshop-eksctl --approve
```

We can confirm we succeeded by retrieving the versions of each with the commands:
```bash
kubectl get daemonset kube-proxy --namespace kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
kubectl describe deployment coredns --namespace kube-system | grep Image | cut -d "/" -f 3
```
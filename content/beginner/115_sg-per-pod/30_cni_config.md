---
title: "CNI configuration"
date: 2020-12-02T21:30:00-05:00
draft: false
weight: 30
---

First we need to attach a new IAM policy the nodes' role to allow them to manage network interfaces, their private IP addresses, and their attachment and detachment to and from instances.

The following command adds the policy `AmazonEKSVPCResourceController` to a cluster role.

```bash
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController \
    --role-name ${ROLE_NAME}
```

Next, we will enable the CNI plugin to manage network interfaces for pods by setting the `ENABLE_POD_ENI` variable to true in the aws-node `DaemonSet`.

```bash
kubectl -n kube-system set env daemonset aws-node ENABLE_POD_ENI=true

# let's way for the rolling update of the daemonset
kubectl -n kube-system rollout status ds aws-node
```

Once this setting is set to true, for each node in the cluster the plugin adds a label with the value `vpc.amazonaws.com/has-trunk-attached=true`. The VPC resource controller creates and attaches one special network interface called a trunk network interface with the description aws-k8s-trunk-eni.

```bash
kubectl get nodes --show-labels
```

![sg-per-pod_4](/images/sg-per-pod/sg-per-pod_4.png)

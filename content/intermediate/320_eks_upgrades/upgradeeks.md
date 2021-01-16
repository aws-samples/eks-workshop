---
title: "Upgrade EKS Control Plane"
weight: 322
---

The first step of this process is to upgrade the EKS Control Plane.

Since we used eksctl to provision our cluster we'll use that tool to do our upgrade as well.

First we'll run this command
```bash
eksctl upgrade cluster --name=eksworkshop-eksctl
```

You'll see in the output that it found our cluster, worked out that it is 1.17 and the next version is 1.18 (you can only go to the next version with EKS) and that everything is ready for us to proceed with an upgrade.
```
$ eksctl upgrade cluster --name=eksworkshop-eksctl
[ℹ]  eksctl version 0.36.0
[ℹ]  using region ap-southeast-2
[ℹ]  (plan) would upgrade cluster "eksworkshop-eksctl" control plane from current version "1.17" to "1.18"
[ℹ]  re-building cluster stack "eksctl-eksworkshop-eksctl-cluster"
[✔]  all resources in cluster stack "eksctl-eksworkshop-eksctl-cluster" are up-to-date
[ℹ]  checking security group configuration for all nodegroups
[ℹ]  all nodegroups have up-to-date configuration
[!]  no changes were applied, run again with '--approve' to apply the changes
```

We'll run it again with an --approve appended to proceed
```bash
eksctl upgrade cluster --name=eksworkshop-eksctl --approve
```
{{% notice info %}}
This process should take approximately 25 minutes. You can continue to use the cluster during the control plane upgrade process but you might experience minor service interruptions. For example, if you attempt to connect to one of the EKS API servers just before or just after it's terminated and replaced by a new API server running the new version of Kubernetes, you might experience temporary API call errors or connectivity issues. If this happens, retry your API operations until they succeed. Your existing Pods/workloads running in the data plane should not experience any interruption during the control plane upgrade.
{{% /notice %}}

{{% notice info %}}
Given how long this step will take and that the cluster will continue to work maybe move on to other workshop chapters until this process completes then come back to finish once it completes.
{{% /notice %}}
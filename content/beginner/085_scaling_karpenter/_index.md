---
title: "Autoscaling with Karpenter"
chapter: true
weight: 85
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - beginner
  - CON205
---

# Implement Autoscaling with Karpenter

{{< youtube _FXRIKWJWUk >}}

In this section you will setup [Karpenter](https://github.com/aws/karpenter). Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters. 


![EKS](/images/karpenter_banner.png)


Karpenter's goal is to improve the efficiency and cost of running workloads on Kubernetes clusters. Karpenter works by:

* Watching for pods that the Kubernetes scheduler has marked as unschedulable
* Evaluating scheduling constraints (resource requests, nodeselectors, affinities, tolerations, and topology spread constraints) requested by the pods
* Provisioning nodes that meet the requirements of the pods
* Removing the nodes when the nodes are no longer needed
* With the right infrastructure, karpenter managed the node termination handling
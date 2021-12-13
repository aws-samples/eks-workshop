---
title: "Autoscaling our Clusters using Karpenter"
chapter: true
weight: 80
tags:
  - beginner
  - CON205
---

# Implement AutoScaling with Karpenter

In this section we will setup [Karpenter](https://github.com/aws/karpenter). Karpenter is an open-source autoscaling project built for Kubernetes. Karpenter is designed to provide the right compute resources to match your application’s needs in seconds, instead of minutes by observing the aggregate resource requests of unschedulable pods and makes decisions to launch and terminate nodes to minimize scheduling latencies.


![EKS](/images/karpenter_banner.png)


Karpenter's goal is to improve the efficiency and cost of running workloads on Kubernetes clusters. Karpenter works by:

* Watching for pods that the Kubernetes scheduler has marked as unschedulable
* Evaluating scheduling constraints (resource requests, nodeselectors, affinities, tolerations, and topology spread constraints) requested by the pods
* Provisioning nodes that meet the requirements of the pods
* Scheduling the pods to run on the new nodes
* Removing the nodes when the nodes are no longer needed



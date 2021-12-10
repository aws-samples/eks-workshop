---
title: "Autoscaling our Clusters using Karpenter"
chapter: true
weight: 80
tags:
  - beginner
  - CON205
---

# Implement AutoScaling with Karpenter

In this Chapter, we will show how to use karpenter to scale your cluster.

[Karpenter](https://github.com/aws/karpenter) is an open-source node provisioning project built for Kubernetes. Its goal is to improve the efficiency and cost of running workloads on Kubernetes clusters. Karpenter works by:

* Watching for pods that the Kubernetes scheduler has marked as unschedulable
* Evaluating scheduling constraints (resource requests, nodeselectors, affinities, tolerations, and topology spread constraints) requested by the pods
* Provisioning nodes that meet the requirements of the pods
* Scheduling the pods to run on the new nodes
* Removing the nodes when the nodes are no longer needed

For most use cases, a cluster’s capacity can be managed by a single Karpenter Provisioner. However, you can define multiple Provisioners, enabling use cases like isolation, entitlements, and sharding. Using a combination of defaults and overrides, Karpenter determines the availability zone, instance type, capacity type, machine image, and scheduling constraints for pods it manages.

[Karpenter](https://karpenter.sh/) automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters. Karpenter is an alternative to cluster autoscaler but they are not mutually exclusive.


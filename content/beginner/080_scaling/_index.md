---
title: "Autoscaling our Applications and Clusters"
chapter: true
weight: 80
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - beginner
  - CON205
---

# Implement AutoScaling with HPA and CA

{{< youtube emjxGvGhWm0 >}}

In this Chapter, we will show patterns for scaling your worker nodes and applications deployments automatically.

Automatic scaling in K8s comes in two forms:

* **Horizontal Pod Autoscaler (HPA)** scales the pods in a deployment or replica set. It is implemented as a K8s API resource and a controller. The controller manager queries the resource utilization against the metrics specified in each HorizontalPodAutoscaler definition. It obtains the metrics from either the resource metrics API (for per-pod resource metrics), or the custom metrics API (for all other metrics).

* **Cluster Autoscaler (CA)** a component that automatically adjusts the size of a Kubernetes Cluster so that all pods have a place to run and there are no unneeded nodes.

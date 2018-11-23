---
title: "Autoscaling our Applications and Clusters"
chapter: true
weight: 41
---

# Implement AutoScaling with HPA and CA

In this Chapter, we will show patterns for scaling your worker nodes and applications deployments automatically. Automatic scaling in K8s comes in two forms:

* **Horizontal Pod Autoscaler (HPA)** scales the pods in a deployment or replica set. It is implemented as a K8s API resource and a controller. The controller manager queries the resource utilization against the metrics specified in each HorizontalPodAutoscaler definition. It obtains the metrics from either the resource metrics API (for per-pod resource metrics), or the custom metrics API (for all other metrics).

* **Cluster Autoscaler (CA)** is the default K8s component that can be used to perform pod scaling as well as scaling nodes in a cluster. It automatically increases the size of an Auto Scaling group so that pods have a place to run. And it attempts to remove idle nodes, that is, nodes with no running pods.

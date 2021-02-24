---
title: "Container Insights"
date: 2020-01-27T08:30:11-07:00
weight: 91
draft: false
---

#### Container Insights

CloudWatch Container Insights is a fully managed service that collects, aggregates, and summarizes Amazon EKS metrics and logs. 
The CloudWatch Container Insights dashboard gives you access to the following information:

* CPU and memory utilization
* Task and service counts
* Read/write storage
* Network Rx/Tx
* Container instance counts for clusters, services, and tasks

Log into console, navigate to Cloudwatch -> Container Insights -> Performance monitoring, you can see the `EKS Cluster` insight
![cluster_insight1](/images/app_mesh_fargate/cluster_insight1.png)

You can change the dropdown to `EKS Nodes` to see the Nodes insight
![node_insight1](/images/app_mesh_fargate/node_insight1.png)

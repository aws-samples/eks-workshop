---
title: "Autoscaling - Part 1"
date: 2021-04-08T01:29:46-07:00
weight: 40
draft: false
---

Autoscaling in EKS is achieved using Cluster Autoscaler.

When resources are not available EKS will add new nodes to the cluster to create new pods and execute the jobs.

Refer to [Cluster autoscaler](beginner/080_scaling/deploy_ca/) section in order to configure the cluster autoscaler.
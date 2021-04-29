---
title: "Autoscaling - Part 2"
date: 2021-04-08T01:29:46-07:00
weight: 45
draft: false
---

Now that we have autoscaling configured. Let's create  spark job that will require more resources than 
Autoscaling in EKS is achieved using Cluster Autoscaler.

When resources are not available EKS will add new nodes to the cluster to create new pods and execute the jobs.

Refer to [Cluster autoscaler](beginner/080_scaling/deploy_ca/) section in order to configure the cluster autoscaler.





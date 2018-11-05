---
title: "Managing Spot Workers"
chapter: true
weight: 55
draft: false
---

# Managing Spot Workers

In this Chapter, we will prepare our cluster to handle Spot interruptions. 

If the available On-Demand capacity of a particular instance type is depleted, the Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things. We will deploy a pod on each spot instance to detect and redeploy applications elsewhere in the cluster

{{% children showhidden="false" %}}

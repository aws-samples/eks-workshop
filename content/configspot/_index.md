---
title: "'Working' With Spot Workers"
chapter: true
weight: 57
draft: false
---

# 'Working' With Spot Workers

In this Chapter, we will prepare our cluster to handle Spot Interruptions. If the available On-Demand capacity of a particular instance type is depleted, the Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things. We will deploy a pod on each spot instance to detect and redeploy applications elsewhere in the cluster

{{% children showhidden="false" %}}

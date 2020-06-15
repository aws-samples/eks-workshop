---
title: "Headroom - A Buffer For Faster Scale Out"
date: 2019-04-09T00:00:00-03:00
weight: 14
draft: false
---

### Keeping Scale-Up Proactive
One of the key features of the Ocean Autoscaler, is the ability to maintain a dynamic buffer of spare capacity called Headroom. The buffer is algorithmically tailored to meet the actual requirements of the incoming containerized workloads which enables immediate pod scheduling. This is perfect for workloads that make use of Horizontal Pod Autoscaler, and helps prevent pending pods which scale scale-out of worker nodes a proactive process, instead of the reactive nature of Kubernetes Cluster-Autoscaler.

Headroom is configurable via the Ocean Cluster's "Actions" menu, under "Customize Scaling":
<img src="/images/ocean/actions_customize_scaling.png" alt="Actions - Customize Scaling" />

The Headroom can be configured Automatically, or Manually. The automatic option would derive the size and number of headroom units from the most common pods in the cluster. The total percentage of the cluster capacity (in terms of CPU and Memory) that will be reserved for Headroom, is configurable. The default value, recommended for most use cases is 5%.

The manual option allows you to tailor the headroom units to your own specification, but note that the defined headroom capacity will end up being static (as opposed to the automatic configuration, which scales with the cluster).

<img src="/images/ocean/customize_scaling.png" alt="Customize Scaling" width="700"/>

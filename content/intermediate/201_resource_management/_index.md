---
title: "Resource Management"
chapter: true
weight: 201
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - intermediate
---

# Resource Management

{{< youtube WDDtR_dsQoQ >}}

[Kubernetes Request](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) is used to ensure a `Pod` has enough defined resources available. It is possible for the `Pod` to use more than what is specified. This is considered a *soft* limit. 

[Kubernetes Limit](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits)  is a used to ensure a `Pod`  does not use above what is specified. This is considered a *hard* limit. 

[Kubernetes Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/) is used to limit resource usage per namespace. 

[Kubernetes Pod Priority and Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) is a used to apply priorities to pods relative to other pods. If a pod cannot be placed on a node, it may preempt or evict lower priority pods. 



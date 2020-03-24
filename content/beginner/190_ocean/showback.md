---
title: "Showback - Cost Allocation"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---

### Kubernetes Workload Cost Showback

Ocean provides you with advanced Cost Analysis for your EKS cluster, with detailed showback which delivers visibility down to the application level. 

Found under Cost Analysis tab of the Ocean Console, the data can be aggregated in several ways:

 - Namespace: With namespaces being used to create logical groupings within a cluster, this is a very straightforward way to identify which environment, team or other grouping is responsible for the associated cost. This cost analysis option will show you both the aggregated spend per namespace as well as a breakdown of spend by deployments and other K8s objects within that namespace.
 - Namespace/Resource Label: This  option shows a spend breakdown of namespaces or K8s resrources that have been given a specific label key. 
 - Namespace/Resource Annotaion: Similar to Label filtering, Ocean can aggregate cost analysis for namespaces and resources that have been annotated with a particular key.

<img src="/images/ocean/showback.png" alt="Showback" width="700"/>

In addition to the aggregation options described above, if you wish to only look at a subset of your cluster, either based on labels or annotations, you can create a custom filter via the "Add Filter" button. For example, if you wish to view only the costs incurred by your K8s application manager, Helm, select the relevant type (label/annotation), the key, an operator (e.g. equals, exists, etc.) and the desired key value. 

<img src="/images/ocean/showback_filter.png" alt="Showback Filter" width="700"/>



---
title: "Stateful containers using StatefulSets"
chapter: true
weight: 170
tags:
  - beginner
  - CON206
---

# Stateful containers using StatefulSets

[StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods, suitable for applications that require one or more of the following.
* Stable, unique network identifiers
* Stable, persistent storage
* Ordered, graceful deployment and scaling
* Ordered, automated rolling updates

In this Chapter, we will review how to deploy MySQL database using `StatefulSet` and `Amazon Elastic Block Store` (EBS) as [PersistentVolume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). The example is a MySQL single master topology with multiple slaves running asynchronous replication.

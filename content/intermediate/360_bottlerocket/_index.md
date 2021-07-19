---
title: "Bottlerocket on EKS"
date: 2021-04-28T07:49:11-07:00
chapter: true
weight: 360
tags:
  - intermediate
  - bottlerocket
  - operations
---

# Bottlerocket on EKS

[Bottlerocket](https://aws.amazon.com/bottlerocket/) is a Linux based open-source OS by AWS for running containers. Several aspects of the host operating system fall under the responsibility of customer when running containers on EKS nodes. While [managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) help with provisioning and lifecycle management of the EKS nodes, Bottlerocket OS helps further by running the nodes with decresed usage of storage, compute and network.

Bottlerocket OS is optimized for running containerized workloads. Only essential packages are included as part of this open source OS which helps reduce the security attack surface. The OS updates are applied in a single unit and can be rolled back easily in case of failures. AWS support plans cover AWS-approved builds of Bottlerocket on EC2.

In this chapter, we will create self-managed and managed node groups using Bottlerocket. We will launch sample workloads on these nodes and explore the features of Bottlerocket
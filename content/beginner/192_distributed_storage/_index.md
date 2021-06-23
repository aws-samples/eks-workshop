---
title: "Building distributed storage with Amazon EBS, Rook and Ceph"
chapter: true
weight: 190
tags:
  - beginner
---

# Building a distributed storage based on Amazon EBS, Rook and Ceph

[Rook](https://rook.io/) is an open source cloud-native storage orchestrator for Kubernetes that includes support for a set of storage solutions which can be natively integrates with cloud infrastructure components. We'll use Rook as storage orchestrator to add and manage Ceph as distributed block storage provider into our Amazon EKS cluster. 

[Ceph](https://ceph.io/) is a unified, distributed storage system that provides file, block and object storage. 

[Amazon EBS](https://aws.amazon.com/ebs/) is an easy to use, high perfomance block storage service for both throughput and transaction intensive workloads at any scale. 

Amazon EBS will provide the underlying storage infrastructure Ceph will use to offer block storage volumes to the pods within our cluster. 
---
title: "CIS EKS Benchmark assessment using kube-bench"
chapter: true
weight: 300
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
draft: false
tags:
  - intermediate
  - cis eks benchmark
  - kube-bench
---

# CIS EKS Benchmark assessment using kube-bench

{{< youtube SxKIz2y8ANE >}}

Security is a critical component of configuring and maintaining Kubernetes clusters and applications. Amazon EKS provides secure, managed Kubernetes clusters by default, but you still need to ensure that you configure the nodes and applications you run as part of the cluster to ensure a secure implementation. 

Since [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes/) provides good practice guidance on security configurations for Kubernetes clusters, customers asked us for guidance on CIS Kubernetes Benchmark for Amazon EKS to meet their security and compliance requirements.

In this chapter, we take a look at how to assess the Amazon EKS cluster nodes you have created against the CIS EKS Kubernetes benchmark.

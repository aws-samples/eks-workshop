---
title: "Introduction to CIS Amazon EKS Benchmark and kube-bench"
weight: 10
draft: false
---

#### CIS Kubernetes Benchmark

The latest version of CIS Kubernetes Benchmark [v1.5.1](https://www.cisecurity.org/benchmark/kubernetes/) provides guidance on security configurations for Kubernetes versions v1.15 and onwards. The CIS Kubernetes Benchmark is scoped for implementations managing both the control plane, which includes etcd, API server, controller and scheduler, and the data plane, which is made up of one or more nodes or EC2 instances.

#### CIS EKS Kubernetes Benchmark

Since Amazon EKS provides a managed control plane, not all of the recommendations from the CIS Kubernetes Benchmark are applicable as customers are not responsible for configuring or managing the control plane. 

CIS Amazon EKS Benchmark [v1.0.0](https://www.cisecurity.org/cis-benchmarks/) provides guidance for node security configurations for Kubernetes and aligns with CIS Kubernetes Benchmark v1.5.1.

{{% notice info %}}
Note: The CIS committee agreed to remove controls for the appropriate control plane recommendations from the managed Kubernetes benchmarks. The CIS Amazon EKS Benchmark consists of four sections on control plane logging configuration, worker nodes, policies and managed services. 
{{% /notice %}}

#### [aquasecurity/kube-bench](https://github.com/aquasecurity/kube-bench)

[kube-bench](https://github.com/aquasecurity/kube-bench) is a popular open source CIS Kubernetes Benchmark assessment tool created by [AquaSecurity](https://www.aquasec.com/). kube-bench is a Go application that checks whether Kubernetes is deployed securely by running the checks documented in the CIS Kubernetes Benchmark. Tests are configured with YAML files, and this makes `kube-bench` easy to update as test specifications evolve. AquaSecurity is an [AWS Advanced Technology Partner](https://aws.amazon.com/partners/find/partnerdetails/?n=Aqua%20Security&id=001E000001LiLQqIAN).


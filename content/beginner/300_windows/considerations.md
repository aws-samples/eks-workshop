---
title: "Considerations"
date: 2020-07-27T11:39:53-04:00
draft: false
weight: 310
---

Before deploying Windows nodes, be aware of the following considerations.

* Windows workloads are supported with Amazon EKS clusters running Kubernetes version 1.14 or later.
* Amazon EC2 instance types C3, C4, D2, I2, M4 (excluding m4.16xlarge), and R3 instances are not supported for Windows workloads.
* Host networking mode is not supported for Windows workloads.
* Amazon EKS clusters must contain one or more Linux nodes to run core system pods that only run on Linux, such as coredns and the VPC resource controller.
* The `kubelet` and `kube-proxy` event logs are redirected to the EKS Windows Event Log and are set to a 200 MB limit.
* Windows nodes support one elastic network interface per node. The number of pods that you can run per Windows node is equal to the number of IP addresses available per elastic network interface for the node's instance type, minus one. For more information, see IP addresses per network interface per instance type in the Amazon EC2 User Guide for Linux Instances.
* Group Managed Service Accounts (GMSA) for Windows pods and containers is not supported by Amazon EKS versions earlier than 1.16. You can follow the instructions in the Kubernetes documentation to enable and test this alpha feature on clusters that are earlier than 1.16.

{{% notice info %}}
GMSA use case is not covered in this lab but you can find more information in this [blog post](https://aws.amazon.com/blogs/containers/how-to-run-eks-windows-containers-with-group-managed-service-account-gmsa/).
{{% /notice %}}

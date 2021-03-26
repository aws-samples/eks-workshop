---
title: "Patching/Upgrading your EKS Cluster"
chapter: true
weight: 320
draft: false
tags:
  - intermediate
  - operations
---

# Patching/Upgrading your EKS Cluster

As EKS tracks upstream Kubernetes that means that customers can, and should, regularly upgrade their EKS so as to stay within the project's upstream support window. This used to be the current version and two version back (n-2) - but it was [recently extended to three versions back (n-3)](https://kubernetes.io/blog/2020/08/31/kubernetes-1-19-feature-one-year-support/). 

There is a new major version of Kubernetes every quarter which means that the Kubernetes support window has now gone from three quarters of a year to one full year.

In addition to upgrades to Kuberentes, there are other related upgrades to think about with your cluster as well:

- The Amazon Machine Image (AMI) of your Nodes - including not just the portion of Kubernetes that is part of the image, the kubelet, but everything else there (OS, containerd, etc.). The control plane always supports managing kubelets that are one version behind itself (n-1) to help faciliatet this upgrade.
- The foundational DaemonSets that are on deployed onto every EKS cluster (kube-proxy, CoreDNS and the AWS CNI) which may need to be upgraded as you upgrade Kubernetes. Our documentation [tells you](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html#w665aac14c15b5c17) if this is required and which versions you should upgrade to.
- And any Add-ons/Controllers/Drivers that you've added to extend Kubernetes and provide important cluster functionality may need to be upgraded as you upgrade Kuberentes

In this Chapter you'll follow the AWS suggested process to upgrade your cluster from 1.17 to 1.18 including its Managed Node Group to get first-hand experience with this process and where EKS and Managed Node Groups help.
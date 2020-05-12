---
title: "Optimized Worker Node Management with Ocean by Spot.io"
chapter: true
weight: 190
tags:
  - beginner
---

# Optimized Worker Node Management with Ocean by Spot.io



### Introduction
[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer AWS customers up to 90% cost savings in comparison to On-Demand Instances. However, they can be interrupted with a 2 minute warning when EC2 needs the capacity back. While this itself does not pose any issue for stateless workloads such as those typically running on Amazon EKS, managing larger clusters running Spot Instances as worker nodes on your own, does require a large amount of manual configuration, setup and maintenance.

For AWS customers looking for a turn-key solution that doesn’t require significant time and effort, Ocean abstracts the nitty-gritty, EKS infrastructure management and provides an enterprise-level SLA for high availability, and data persistence. 

The result is that your EKS cluster will automatically run on an optimal blend of Spot Instances, Savings Plans and Reserved Instances as well as On-Demand when needed, so you can focus on higher value activities. 

### Prerequisites
 - An AWS Account.
 - An existing EKS cluster.
 - An installed and configured `kubectl`.

### What you will achieve
After concluding this module, you will be set up with Ocean by Spot.io (previously Spotinst), understand the benefits it brings to EKS users and will be able to run a fully optimized EKS cluster, with ease and confidence.

{{% notice note %}}
Throughout this module we will be working with the Console UI, and use of the AWS vended version of `eksctl` is assumed. However, you should know that there is an Ocean integrated version of `eksctl`, which allows you to streamline and optimize the entire process. If you wish to learn more about the Spot.io vended version of `eksctl` click [here](https://spot.io/blog/eks-done-right-from-control-plane-to-worker-nodes/).
{{% /notice %}}


<img src="/images/ocean/ocean_overview.png" alt="Ocean Overview" width="700"/>



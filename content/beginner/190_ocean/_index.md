---
title: "Optimized Worker Node Management with Spot Ocean"
chapter: true
weight: 190
tags:
  - intermediate
  - CON203
---

# Optimized Worker Node Management with Spot Ocean

<img src="/images/ocean/spot_logo.png" alt="Spot Logo" width="300"/>

### Introduction
[EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer AWS customers up to 90% cost savings in comparison to On-Demand Instances. However, they can be interrupted with just a 2 minute warning. While this itself does not pose any issue for stateless workloads such as those typically running on EKS, managing larger clusters of AWS Spot Instances on your own, does require a large amount of manual configuration, setup and maintenance.

For AWS customers looking for a turn-key solution that doesn’t require significant time and effort, Ocean abstracts the nitty-gritty, EKS infrastructure management and provides an enterprise-level SLA for high availability, and data persistence. 

The result is that your EKS cluster will automatically run on an optimal blend of Spot Instances, Savings Plans and Reservations as well as On-Demand when needed, so you can focus on higher value activities. 

### Prerequisites
 - An AWS Account.
 - An existing EKS cluster.
 - An installed and configured `kubectl`.

### What will you achieve
After concluding this chapter, you will be set up with Spot Ocean, understand the benefits it brings to EKS users and will be able to run a fully optimized EKS cluster, with ease and confidence.

{{% notice note %}}
Throughout this chapter we will be working with the Console UI, and use of the AWS vended version of `eksctl` is assumed. However, you should know that there is an Ocean integrated version of `eksctl`, which allows you to streamline and optimize the entire process. If you wish to learn more about the Spot vended version of `eksctl` click [here](https://spot.io/blog/eks-done-right-from-control-plane-to-worker-nodes/).
{{% /notice %}}


<img src="/images/ocean/ocean_overview.png" alt="Ocean Overview" width="700"/>



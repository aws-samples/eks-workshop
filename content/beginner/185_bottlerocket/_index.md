---
title: "Deploy Bottlerocket nodes for additional security"
chapter: true
weight: 180
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - beginner
---

# Deploying Bottlerocket nodes to your cluster

[Bottlerocket](https://aws.amazon.com/bottlerocket/) is a Linux-based open-source operating system that is purpose-built by Amazon Web Services for running containers. Bottlerocket includes only the essential software required to run containers, and ensures that the underlying software is always secure. With Bottlerocket, customers can reduce maintenance overhead and automate their workflows by applying configuration settings consistently as nodes are upgraded or replaced. Bottlerocket is now generally available at no cost as an Amazon Machine Image (AMI) for Amazon Elastic Compute Cloud (EC2).

In this Chapter, we will deploy three Bottlerocket-based nodes and deploy an nginx pod on one of them.

---
title: "Deploying Microservices to EKS Fargate"
chapter: true
weight: 180
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - beginner
  - CON206
---

# Deploying Microservices to EKS Fargate

{{< youtube J67CHCXHMxw >}}

[AWS Fargate](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html) is a technology that provides on-demand, right-sized compute capacity for containers. With AWS Fargate, you no longer have to provision, configure, or scale groups of virtual machines to run containers. This removes the need to choose server types, decide when to scale your node groups, or optimize cluster packing. You can control which pods start on Fargate and how they run with [Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html), which are defined as part of your Amazon EKS cluster.

In this Chapter, we will deploy the game [2048 game](http://play2048.co) on EKS Fargate and expose it to the Internet using an Application Load balancer.

---
title: "Deploying Stateful Microservices with AWS EFS"
chapter: true
weight: 190
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - beginner
  - CON206
---

# Deploying Stateful Microservices with AWS EFS

{{< youtube MvwQiHAuduc >}}

Amazon Elastic File System (Amazon EFS) provides a simple, scalable, fully managed elastic NFS file system for use with AWS Cloud services and on-premises resources. It is built to scale on demand to petabytes without disrupting applications, growing and shrinking automatically as you add and remove files, eliminating the need to provision and manage capacity to accommodate growth.

Amazon EFS supports the Network File System version 4 (NFSv4.1 and NFSv4.0) protocol, so the applications and tools that you use today work seamlessly with Amazon EFS. Multiple Amazon EC2 instances can access an Amazon EFS file system at the same time, providing a common data source for workloads and applications running on more than one instance or server. For an Amazon EFS technical overview, see [Amazon EFS: How It Works](https://docs.aws.amazon.com/efs/latest/ug/how-it-works.html).

In this Chapter, you will create an EFS file system and share it across a set of stateful microservices deployed on AWS EKS which can all have concurrent access to the file system.

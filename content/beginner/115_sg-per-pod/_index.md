---
title: "Security Groups per Pod"
date: 2020-11-26T13:01:55-05:00
weight: 115
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
draft: false
chapter: true
tags:
  - beginner
---

# Security groups per pods

Containerized applications frequently require access to other services running within the cluster as well as external AWS services, such as Amazon Relational Database Service (Amazon RDS) or Amazon ElastiCache.

On AWS, controlling network level access between services is often accomplished via EC2 security groups and [Security groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html), acting as instance level network firewalls to control incoming and outgoing traffic, are among the most important and commonly used building blocks in any AWS cloud deployment.

It came as no surprise to us that integrating security groups with Kubernetes pods emerged as one of the most highly requested Amazon Elastic Kubernetes Service (Amazon EKS) features. Before the release of this new functionality, you could only assign security groups at the node level, and every pod on all nodes shared the same security groups even if only the green pod was the only one needing access to the RDS Database.

![sg-per-pod_1](/images/sg-per-pod/sg-per-pod_1.png)

To work around this limitation, you had to spin up separate node groups per application and configure complicated taint and affinity rules to schedule pods onto the right nodes. This inefficient process is difficult to manage at scale and can result in underutilized nodes as shown below.

![sg-per-pod_2](/images/sg-per-pod/sg-per-pod_2.png)

[Security groups for pods](https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html) integrate Amazon EC2 security groups with Kubernetes pods. You can use Amazon EC2 security groups to define rules that allow inbound and outbound network traffic to and from pods that you deploy to nodes running on many Amazon EC2 instance types. For a detailed explanation of this capability, [see the Introducing security groups for pods blog post](https://aws.amazon.com/blogs/containers/introducing-security-groups-for-pods/).

![sg-per-pod_3](/images/sg-per-pod/sg-per-pod_3.png)

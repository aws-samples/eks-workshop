---
title: "Security Groups per Pod"
date: 2020-11-26T13:01:55-05:00
weight: 115
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
draft: false
chapter: false
tags:
  - beginner
---

### Introduction

Containerized applications frequently require access to other services running within the cluster as well as external AWS services, such as Amazon Relational Database Service (Amazon RDS) or Amazon ElastiCache.

On AWS, controlling network level access between services is often accomplished via [Security groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html).

Before the release of this new functionality, you could only assign security groups at the node level and all the nodes included in a Node groupe shared the same security groups.

So by allowing the Node group security group to access the RDS instance, all the pods will have access the database even if only the green pod should have access.

![sg-per-pod_1](/images/sg-per-pod/sg-per-pod_1.png)

<!-- To work around this limitation, you had to spin up separate node groups per application and configure complicated taint and affinity rules to schedule pods onto the right nodes. This inefficient process is difficult to manage at scale and can result in underutilized nodes as shown below.

![sg-per-pod_2](/images/sg-per-pod/sg-per-pod_2.png) -->

[Security groups for pods](https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html) integrate Amazon EC2 security groups with Kubernetes pods. You can use Amazon EC2 security groups to define rules that allow inbound and outbound network traffic to and from pods that you deploy to nodes running on many Amazon EC2 instance types. For a detailed explanation of this capability, [see the Introducing security groups for pods blog post](https://aws.amazon.com/blogs/containers/introducing-security-groups-for-pods/).

{{% notice note %}}
For more information, don't hesitate to read our [blog](https://aws.amazon.com/blogs/containers/introducing-security-groups-for-pods/) or the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html).
{{% /notice %}}

### Objectives

During this section of the workshop:

* We will create an [Amazon RDS database](https://aws.amazon.com/rds/) protected by a security group.
* We will create a security group called POD_SG that will be able to access the RDS instance.
* Then we will deploy a `SecurityGroupPolicy` that will automatically attach the POD_SG security group to a pod with the correct metadata.
* When the RDS instance is ready we will deploy two pods (green and red) using the same image and verify that only one of them (green) can connect to RDS.

![sg-per-pod_3](/images/sg-per-pod/sg-per-pod_3.png)

---
title: "Security groups for pods"
date: 2020-11-26T13:01:55-05:00
weight: 115
#pre: '<i class="fa fa-film" aria-hidden="true"></i> '
draft: false
chapter: false
tags:
  - beginner
---

### Introduction

Containerized applications frequently require access to other services running within the cluster as well as external AWS services, such as [Amazon Relational Database Service](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiYkYfF9bHtAhWEwFkKHT6nD7kQFjAAegQIARAD&url=https%3A%2F%2Faws.amazon.com%2Frds%2F&usg=AOvVaw1EJQFNeMAoVICsb0iec7IR) (Amazon RDS).

On AWS, controlling network level access between services is often accomplished via [security groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html).

Before the release of this new functionality, you could only assign security groups at the node level. And because all nodes inside a Node group share the security group, by allowing the Node group security group to access the RDS instance, all the pods running on theses nodes would have access the database even if only the green pod should have access.

![sg-per-pod_1](/images/sg-per-pod/sg-per-pod_1.png)

[Security groups for pods](https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html) integrate Amazon EC2 security groups with Kubernetes pods. You can use Amazon EC2 security groups to define rules that allow inbound and outbound network traffic to and from pods that you deploy to nodes running on many Amazon EC2 instance types. For a detailed explanation of this capability, see [the Introducing security groups for pods blog post](https://aws.amazon.com/blogs/containers/introducing-security-groups-for-pods/) and the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html).

### Objectives

During this section of the workshop:

* We will create an Amazon RDS database protected by a security group called RDS_SG.
* We will create a security group called POD_SG that will be allowed to connect to the RDS instance.
* Then we will deploy a `SecurityGroupPolicy` that will automatically attach the POD_SG security group to a pod with the correct metadata.
* Finally we will deploy two pods (green and red) using the same image and verify that only one of them (green) can connect to the Amazon RDS database.

![sg-per-pod_3](/images/sg-per-pod/sg-per-pod_3.png)

---
title: "Service Mesh with AWS App Mesh"
date: 2018-11-13T16:32:30+09:00
weight: 54
draft: false
---

AWS App Mesh (https://aws.amazon.com/app-mesh) is a service mesh helps you to run and monitor HTTP and TCP services at scale. Whether your application consists of AWS Fargate (https://aws.amazon.com/fargate/), Amazon EC2 (https://aws.amazon.com/ec2/), Amazon ECS (https://aws.amazon.com/ecs/), Amazon Elastic Container Service for Kubernetes (https://aws.amazon.com/eks/), or Kubernetes (https://aws.amazon.com/kubernetes/) clusters or instances, App Mesh provides consistent routing and traffic monitoring functionality, giving you insight into problems and the ability to re-route traffic after failures or code changes.

App Mesh uses the open source Envoy (https://www.envoyproxy.io/) proxy, giving you access to a wide range of tools from AWS partners and the open source community.

Since all traffic in and out of each service goes through the Envoy proxy, all traffic can be routed, shaped, measured, and logged.

![App Mesh](/images/app_mesh_ga/150-observable-and-shapable.png)

This extra level of indirection lets you build your services in any desired languages without having to use a common set of communication libraries.

In this series, we'll walk you through setup and configuration of AWS App Mesh for popular platforms and use cases, beginning with Kubernetes on EKS.

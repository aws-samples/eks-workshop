---
title: "Service Mesh with AWS App Mesh"
date: 2018-08-07T08:30:11-07:00
weight: 320
aliases:
    - /mesh/
    - /appmesh/
tags:
  - advanced
  - operations
  - servicemesh
  - appmesh
---

At [re:invent 2018](https://www.youtube.com/watch?v=GVni3ruLSe0), we announced [AWS App Mesh](https://aws.amazon.com/app-mesh), a service mesh that provides application-level networking to make it easy for your services to communicate with each other across multiple types of compute infrastructure. App Mesh standardizes how your services communicate, giving you end-to-end visibility and ensuring high-availability for your applications.

Service meshes like AWS App Mesh help you to run and monitor HTTP and TCP services at scale. Whether your application consists of [AWS Fargate](https://aws.amazon.com/fargate/), [Amazon EC2](https://aws.amazon.com/ec2/), [Amazon ECS](https://aws.amazon.com/ecs/), [Amazon Kubernetes Service](https://aws.amazon.com/eks/), or [Kubernetes](https://aws.amazon.com/kubernetes/) clusters or instances, App Mesh provides consistent routing and traffic monitoring functionality, giving you insight into problems and the ability to re-route traffic after failures or code changes.

App Mesh uses the open source [Envoy](https://www.envoyproxy.io/) proxy, giving you access to a wide range of tools from AWS partners and the open source community.  Since all traffic in and out of each service goes through the Envoy proxy, all traffic can be routed, shaped, measured, and logged. This extra level of indirection lets you build your services in any desired languages without having to use a common set of communication libraries.

In this tutorial, we'll walk you through many popular App Mesh use cases.

They will take you through building an easy to understand standalone k8s microservices-based application, and then enabling App Mesh service mesh functionality for it.

{{% notice note %}}
The first two sections, [Deploy the DJ App](/advanced/320_servicemesh_with_appmesh/create_the_k8s_app/), and [AWS App Mesh Integration](/advanced/320_servicemesh_with_appmesh/create_app_mesh_components/) should be performed in order.
{{% /notice %}}

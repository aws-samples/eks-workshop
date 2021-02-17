---
title: "Service Mesh using AWS App Mesh"
date: 2020-01-27T08:30:11-07:00
weight: 330
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
aliases:
    - /mesh/
    - /appmesh/
    - /fargate/
tags:
  - advanced
  - operations
  - servicemesh
  - appmesh
  - fargate
---
<!--- 
AWS App Mesh on Amazon EKS
{{< youtube 9SwFFedBhew >}}

Getting Fancy with AWS App Mesh on Amazon EKS
{{< youtube NFpWnHE1Ckw >}}
-->

At [re:invent 2018](https://www.youtube.com/watch?v=GVni3ruLSe0), we announced [AWS App Mesh](https://aws.amazon.com/app-mesh), a service mesh that provides application-level networking to make it easy for your services to communicate with each other across multiple types of compute infrastructure. AWS App Mesh standardizes how your services communicate, giving you end-to-end visibility and ensuring high-availability for your applications.

Service meshes like AWS App Mesh help you to run and monitor HTTP and TCP services at scale. Whether your application consists of [AWS Fargate](https://aws.amazon.com/fargate/), [Amazon EC2](https://aws.amazon.com/ec2/), [Amazon ECS](https://aws.amazon.com/ecs/), [Amazon Kubernetes Service](https://aws.amazon.com/eks/), or [Kubernetes](https://aws.amazon.com/kubernetes/) clusters or instances, AWS App Mesh provides consistent routing and traffic monitoring functionality, giving you insight into problems and the ability to re-route traffic after failures or code changes.

AWS App Mesh uses the open source [Envoy](https://www.envoyproxy.io/) proxy, giving you access to a wide range of tools from AWS partners and the open source community.  Since all traffic in and out of each service goes through the Envoy proxy, all traffic can be routed, shaped, measured, and logged. This extra level of indirection lets you build your services in any desired languages without having to use a common set of communication libraries.

In this tutorial, we'll walk you through the following, which are popular App Mesh use cases using the example of below Product Catalog Application deployment:

* Deploy a microservices-based application in Amazon EKS using AWS Fargate
* Configure an App Mesh Virtual Gateway to route traffic to the application services
* Create a Canary Deployment using App Mesh
* Enable observability features with App Mesh, including logging for Fargate, Amazon Cloudwatch Container Insights, and AWS X-Ray tracing

![fronteend](/images/app_mesh_fargate/lbfrontend-2.png)

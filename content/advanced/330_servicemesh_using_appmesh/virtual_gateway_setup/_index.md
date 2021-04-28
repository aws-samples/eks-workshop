---
title: "VirtualGateway Setup"
date: 2020-01-27T08:30:11-07:00
weight: 40
draft: false
---

A [VirtualGateway](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_gateways.html) allows resources that 
are outside of your mesh to communicate to resources that are inside of your mesh. 
The VirtualGateway represents an Envoy proxy running in an [Amazon EC2 instance](https://aws.amazon.com/ec2/), [Amazon ECS Service](https://aws.amazon.com/ecs/), [Amazon Kubernetes Service](https://aws.amazon.com/eks/). 
Unlike a VirtualNode, which represents Envoy running with an application, a VirtualGateway represents Envoy deployed by itself.

External resources must be able to resolve a DNS name to an IP address assigned to the service or instance that runs Envoy. 
Envoy can then access all of the App Mesh configuration for resources that are inside of the mesh. 

The configuration for handling the incoming requests at the VirtualGateway are specified using Gateway Routes. 
VirtualGateways are affiliated with a load balancer and allow you to configure ingress traffic rules using Routes, similar to VirtualRouter configuration.

![Product Catalog App with App Mesh](/images/app_mesh_fargate/virtualgateway.png)

_Image source:aws.amazon.com/blogs/containers/introducing-ingress-support-in-aws-app-mesh_
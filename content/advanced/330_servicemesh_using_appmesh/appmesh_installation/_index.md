---
title: "App Mesh Installation"
date: 2020-01-27T08:30:11-07:00
weight: 30
draft: false
---

This tutorial guides you through the installation and use of the open source [**AWS App Mesh Controller for Kubernetes**](https://github.com/aws/aws-app-mesh-controller-for-k8s). AWS App Mesh Controller For K8s is a controller to help manage [AWS App Mesh](https://docs.aws.amazon.com/app-mesh/latest/userguide/what-is-app-mesh.html) resources for a Kubernetes cluster and injecting sidecars to Kubernetes Pods. 


The controller maintains the custom resources (CRDs): Mesh, VirtualNode, VirtualService, VirtualRouter, VirtualGateway and GatewayRoute. When using the App Mesh Controller, you manage these App Mesh custom resources such as `VirtualService` and `VirtualNode` through the Kubernetes API the same way you manage native Kubernetes resources such as `Service` and `Deployment`. 

 
The controller monitors your Kubernetes objects, and when App Mesh resources are created or changed it reflects those changes in AWS App Mesh for you. Specification of your App Mesh resources is done through the use of Custom Resource Definitions (CRDs) provided by the App Mesh Controller project. These custom resources map to below App Mesh API objects.

  * [Mesh](https://docs.aws.amazon.com/app-mesh/latest/userguide/meshes.html)
  * [VirtualService](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_services.html)
  * [VirtualNode](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_nodes.html)
  * [VirtualRouter](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_routers.html)
  * [VirtualGateway](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_gateways.html)
  * [GatewayRoute](https://docs.aws.amazon.com/app-mesh/latest/userguide/gateway-routes.html)

For a pod in your application to join a mesh, it must have an open source [Envoy](https://www.envoyproxy.io/) proxy container running as sidecar container within the pod. This establishes the data plane that AWS App Mesh controls. So we must run an Envoy container within each pod of the Product Catalog App deployment.
App Mesh uses the Envoy sidecar container as a proxy for all ingress and egress traffic to the primary microservice. Using this sidecar pattern with Envoy we create the backbone of the service mesh, without impacting our applications.

The controller will handle routine App Mesh tasks such as creating and injecting Envoy proxy containers into your application pods. Automated sidecar injection is controlled by enabling a webhook on a per-namespace basis.

![App Mesh](/images/app_mesh_fargate/pcapp.png)



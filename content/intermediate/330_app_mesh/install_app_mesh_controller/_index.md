---
title: "AWS App Mesh Integration"
date: 2018-11-13T16:32:30+09:00
weight: 20
draft: false
---

This tutorial guides you through the installation and use of the open source [**AWS App Mesh Controller for Kubernetes**](https://github.com/aws/aws-app-mesh-controller-for-k8s). When using the App Mesh Controller, you manage your App Mesh resources such as `Virtual Services` and `Virtual Nodes` through the Kubernetes API the same way you manage native Kubernetes resources such as `Services` and `Deployments`.

The controller monitors your Kubernetes objects, and when App Mesh resources are created or changed it reflects those changes in AWS App Mesh for you. Specification of your App Mesh resources is done through the use of Custom Resource Definitions (CRDs) provided by the App Mesh Controller project. In this tutorial, you will use the following custom resources:

  * [meshes](https://docs.aws.amazon.com/app-mesh/latest/userguide/meshes.html)
  * [virtualservices](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_services.html)
  * [virtualnodes](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_nodes.html)
  * [virtualrouters](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_routers.html)

The controller will handle routine App Mesh tasks such as creating and injecting Envoy proxy containers into your application pods. Automated sidecar injection is controlled by enabling a webhook on a per-namespace basis. This is optional but recommended as it makes using App Mesh in Kubernetes transparent.

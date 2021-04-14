---
title: "Canary Deployment using Flagger in AWS App Mesh"
date: 2018-11-18T00:00:00-05:00
weight: 340
draft: false
tags:
  - advanced
  - appmesh
  - automatedcanary
  - flagger
---

[Flagger](https://docs.flagger.app/) is a progressive delivery tool that automates the release process for applications running on Kubernetes. Flagger can be configured to automate the release process for Kubernetes workloads with a custom resource named canary.

We saw in the [Canary](/advanced/330_servicemesh_using_appmesh/canary_deployment/) chapter of [Service Mesh using App Mesh](/advanced/330_servicemesh_using_appmesh/) workshop on how to deploy new version of `detail` service by changing the VirtualRouter configuration. In this workshop, we will show you how to use Flagger in App Mesh to automate the canary deployment of backend service `detail` of our Product Catalog Application.

![flagger](/images/app_mesh_flagger/flagger.png)

Image source:https://docs.flagger.app/
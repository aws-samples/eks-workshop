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

In the [previous workshop](/advanced/330_servicemesh_using_appmesh/) we saw in the chapter [Canary Release](/advanced/330_servicemesh_using_appmesh/canary_deployment/) on how to deploy new version of `detail` service by changing the VIrtualRouter configuration. In this workshop, we will show you how to use Flagger in App Mesh to automate the canary deployment of backend service `detail` of our Product Catalog Application.

![flagger](/images/app_mesh_fargate/flagger.png)

Image source:https://docs.flagger.app/
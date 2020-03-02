---
title: "AWS App Mesh Integration"
date: 2018-11-13T16:32:30+09:00
weight: 20
draft: false
---

When you use `AWS App Mesh` with Kubernetes, you manage App Mesh resources, such as `virtual services` and `virtual nodes`, that align to Kubernetes resources, such as `services` and `deployments`.
You also add the App Mesh sidecar container images to Kubernetes pod specifications.
This tutorial guides you through the installation of the following open source components that automatically complete these tasks for you when you work with Kubernetes resources:

* **App Mesh controller for Kubernetes** – The controller is accompanied by the deployment of three Kubernetes custom resource definitions:
  * [mesh](https://docs.aws.amazon.com/app-mesh/latest/userguide/meshes.html)
  * [virtual service](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_services.html)
  * [virtual node](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_nodes.html)

  The controller watches for creation, modification, and deletion of the custom resources and makes changes to the corresponding App Mesh mesh, virtual service (including virtual router and route), and virtual node resources through the App Mesh API. To learn more or contribute to the controller, see the [GitHub project](https://github.com/aws/aws-app-mesh-controller-for-k8s).

* **App Mesh sidecar injector for Kubernetes** – The injector installs as a webhook and injects the App Mesh sidecar container images into Kubernetes pods running in specific, labeled namespaces. To learn more or contribute, see the [GitHub project](https://github.com/aws/aws-app-mesh-inject).

---
title: "About Sidecars"
date: 2020-01-27T08:30:11-07:00
weight: 30
---

For a pod in your application to join a mesh, it must have an Envoy proxy container running sidecar within the pod. This establishes the data plane that AWS App Mesh controls. So we must run an Envoy container within each pod of the Product Catalog App deployment. For example:

![App Mesh](/images/app_mesh_fargate/pcapp-2.png)

This can be accomplished a few different ways:

* Before installing the application, you can modify the Product Catalog App `Deployment` container specs to include App Mesh sidecar containers and set a few required configuration elements and environment variables. When pods are deployed, they would run the sidecar.

* After installing the application, you can patch each `Deployment` to include the sidecar container specs. Upon applying this patch, the old pods would be torn down, and the new pods would come up with the sidecar.

* You can enable the AWS App Mesh Sidecar Injector in the meshed namespace, which watches for new pods to be created and automatically adds the sidecar container and required configuration to the pods as they are deployed.

In this tutorial, you will use the third option and enable automatic sidecar injection for your meshed pods.

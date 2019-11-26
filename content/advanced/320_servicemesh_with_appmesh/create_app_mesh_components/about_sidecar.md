---
title: "About Sidecars"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

As decoupled logic, an App Mesh sidecar container must run alongside each pod in the DJ App deployment.  

![App Mesh](/images/app_mesh_ga/101-side-car-proxy.png)


This can be setup in few different ways:


1. Before installing the deployment, we could modify the DJ App deployment's container specs to include App Mesh sidecar containers.  When deployed, it would run the sidecar.

2. After installing the deployment, we could patch the deployment to include the sidecar container specs.  Upon applying this patch, the old pods would be torn down, and the new pods would come up with the sidecar.

3. We can implement the App Mesh Injector Controller, which watches for new pods to be created, and automatically adds the sidecar data to the pods as they are deployed.

For this tutorial, we'll walk through the App Mesh Injector Controller option, as it will enable subsequent pod deployments to come up with the App Mesh sidecar automatically.  This is not only quicker in the long run, but it also reduces the chances of typos that manual editing may introduce.

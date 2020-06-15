---
title: "About Sidecars"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

As decoupled logic, an App Mesh sidecar container must run alongside each pod in the DJ App deployment.  

![App Mesh](/images/app_mesh_ga/djapp-2.png)

This can be setup in few different ways:

* Before installing the deployment, we could modify the DJ App deployment's container specs to include App Mesh sidecar containers.  When deployed, it would run the sidecar.

* After installing the deployment, we could patch the deployment to include the sidecar container specs.  Upon applying this patch, the old pods would be torn down, and the new pods would come up with the sidecar.

* Finally, we can implement the `AWS App Mesh Sidecar Injector`, which watches for new pods to be created, and automatically adds the sidecar data to the pods as they are deployed.

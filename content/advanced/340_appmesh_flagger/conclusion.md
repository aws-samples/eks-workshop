---
title: "Conclusion"
date: 2021-03-18T00:00:00-05:00
weight: 60
draft: false
---

Congratulations on using Flagger in AWS App Mesh to automate the deployment of a new version of the `detail` service!

In this workshop, we have gone through:

* Installing AppMesh in EKS cluster
* Setting up Flagger for AppMesh in EKS cluster
* Flagger Canary setup for backend service `detail`
* We exposed `frontend` service via AppMesh VirtualGateway, `frontend` service calls the backend service `detail`
* We did automated canary promotion from version 1 to version 2 
* We also created a scenario by injecting error for automated canary rollback while deploying version 3
* And lastly we redeployed the version 3 using automated canary promotion
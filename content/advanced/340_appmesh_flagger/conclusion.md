---
title: "Conclusion"
date: 2021-03-18T00:00:00-05:00
weight: 60
draft: false
---

Congrats on automating the rolling out new version of `detail` service using Flagger in AWS App Mesh!

In this chapter, we have gone through:

* Setting up Flagger for AppMesh in EKS cluster
* Flagger Canary setup for backend service `detail`
* We exposed `frontend` service via AppMesh VirtualGateway, `frontend` service calls the backend service `detail`
* We did automated canary promotion from version 1 to version 2 
* We also created a scenario by injecting error for automated canary rollback while deploying version 3


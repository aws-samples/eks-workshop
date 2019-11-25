---
title: "About DJ App"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

The example app we'll walk you through creating on App Mesh is called DJ.  DJ is an application used for a cloud-based music service.

This application is composed of three microservices:

1. dj
2. metal-v1 and
3. jazz-v1

![App Mesh](/images/app_mesh_ga/125-v1-no-mesh.png)

The dj service makes requests to either the jazz or metal backends for artist lists.  If the dj service requests from the jazz backend, musical artists such as Miles Davis or Astrud Gilberto will be returned.  Requests made to the metal backend may return artists such as Judas Priest or Megadeth.

Today, dj is hardwired to make requests to metal-v1 for metal requests, and hardwired to jazz-v1 for jazz requests.  Each time there is a new metal or jazz release, we also need to release a new version of dj as to point to its new upstream endpoints.  It works, but it's not an optimal configuration to maintain for the long term.  

We're going to demonstrate how App Mesh can be used to simplify this architecture; by virtualizing the metal and jazz service, we can dynamically make them route to the endpoints and versions of our choosing, minimizing the need for complete re-deployment of the DJ app each time there is a new metal or jazz service release.  

When we're done, our app will look more like the following:

![App Mesh](/images/app_mesh_ga/155-v2-with-mesh-and-cp.png)

Seven total services with App Mesh sidecars proxying traffic, and the App Mesh control plane managing the sidecars' configuration rulesets.

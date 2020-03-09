---
title: "Porting DJ to App Mesh"
date: 2018-11-13T16:32:30+09:00
weight: 30
draft: false
---

Now that the Injector, CRDs, and App Mesh Controller are defined and running, we're ready to define the App Mesh components required for our service mesh-enabled version of the app.

As we move to this new architecture, what will it look like, and how will it be different?

![App Mesh](/images/app_mesh_ga/135-v1-mesh.png)

Functionally, the service mesh-enabled version will do exactly what the current version does; requests made by `dj` will be served by either the `metal-v1`, or the `jazz-v1` services. The difference will be that we'll use `AWS App Mesh` to create new Virtual Services called metal and jazz.

The metal and jazz Virtual Services will then call their metal-v1 and jazz-v1 counterparts accordingly, based on the Virtual Services' routing rules.

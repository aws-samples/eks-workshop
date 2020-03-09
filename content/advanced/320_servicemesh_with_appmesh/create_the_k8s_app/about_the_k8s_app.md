---
title: "About DJ App"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

## Architecture

The example app we'll walk you through creating on App Mesh is called `DJ` and is used for a cloud-based music service.

This application is composed of three microservices:

* dj
* metal-v1
* jazz-v1

![DJ App without App Mesh](/images/app_mesh_ga/125-v1-no-mesh.png)

The `dj` service makes requests to either the `jazz` or `metal` backends for artist lists:

* Requests made to the `jazz` backend may return artists such as _Miles Davis_ or _Astrud Gilberto_.
* Requests made to the `metal` backend may return artists such as _Judas Priest_ or _Megadeth_.

## Challenge

Today, `dj` is hardwired to make requests to `metal-v1` and `jazz-v1`.

Each time there is a new `metal` or `jazz` release, we also need to release a new version of `dj` as to point to its new upstream endpoints. It works, but it's not an optimal configuration to maintain for the long term.  

## Solution

We're going to demonstrate how `AWS App Mesh` can be used to simplify this architecture; by virtualizing the `metal` and `jazz` service, we can dynamically make them route to the endpoints and versions of our choosing, minimizing the need for complete re-deployment of the `dj` service each time there is a new `metal` or `jazz` service release.  

When we're done, our app will look more like the following:

![DJ App with App Mesh](/images/app_mesh_ga/155-v2-with-mesh-and-cp.png)

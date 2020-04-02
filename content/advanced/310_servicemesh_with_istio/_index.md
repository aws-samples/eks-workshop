---
title: "Service Mesh with Istio"
date: 2018-11-13T16:32:30+09:00
weight: 310
draft: false
tags:
  - advanced
  - operations
  - servicemesh
---

![Service Mesh Architecture](/images/istio/istio-intro1.png)

A service mesh is a dedicated infrastructure layer for handling **service-to-service communication**. It’s responsible for the reliable delivery of requests through the complex topology of services that comprise a modern, cloud native application.

Service mesh solutions have two distinct components that behave somewhat differently:

* The <span style="color:orange">**data plane**</span> is composed of a set of intelligent proxies (Envoy) deployed as sidecars. These proxies mediate and control all network communication between microservices along with Mixer, a general-purpose policy and telemetry hub.
* The <span style="color:orange">**control plane**</span> manages and configures the proxies to route traffic. Additionally, the control plane configures Mixers to enforce policies and collect telemetry.

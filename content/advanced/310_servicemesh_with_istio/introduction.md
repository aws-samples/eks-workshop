---
title: "Introduction"
date: 2018-11-13T16:36:24+09:00
weight: 10
draft: false
---

## Istio

![Istio Architecture](/images/istio/istio_architecture.png)

Istio is a completely open source service mesh that layers transparently onto existing distributed applications. It's also a platform, including APIs, that let it integrate into any logging platform, or telemetry or policy system.

Istio works by having a small network proxy sit alongside each microservice called "sidecar".
It's role is to intercept all of the service’s traffic, and handles it more intelligently than a simple layer 3 network can. [Envoy proxy](https://www.envoyproxy.io/) is used as the sidecar and was originally written at Lyft and is now a CNCF project.

Let's review in more detail what each of the components that make up this service mesh are.

* <span style="color:orange">**Envoy**</span>
  * Processes the inbound/outbound traffic from inter-service and service-to-external-service transparently.

* <span style="color:orange">**Pilot**</span>
  * Pilot provides service discovery for the Envoy sidecars, traffic management capabilities for intelligent routing (e.g., A/B tests, canary deployments, etc.), and resiliency (timeouts, retries, circuit breakers, etc.)

* <span style="color:orange">**Mixer**</span>
  * Mixer enforces access control and usage policies across the service mesh, and collects telemetry data from the Envoy proxy and other services.

* <span style="color:orange">**Citadel**</span>
  * Citadel provides strong service-to-service and end-user authentication with built-in identity and credential management.
  
* <span style="color:orange">**Galley**</span>
  * Galley is Istio’s configuration validation, ingestion, processing and distribution component. It is responsible for insulating the rest of the Istio components from the details of obtaining user configuration from the underlying platform (e.g. Kubernetes).

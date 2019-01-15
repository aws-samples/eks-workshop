---
title: "Introduction"
date: 2018-11-13T16:36:24+09:00
weight: 10
draft: false
---

### Istio

![Istio Architecture](/images/servicemesh-intro2.png)

Istio is a completely open source service mesh that layers transparently onto existing distributed applications. It's also a platform, including APIs, that let it integrate into any logging platform, or telemetry or policy system.

Let's review in more detail what each of the components that make up this service mesh are.

* <span style="color:orange">**Envoy**</span>
  * Processes the inbound/outbound traffic from inter-service and service-to-external-service transparently.

* <span style="color:orange">**Pilot**</span>
  * Pilot provides service discovery for the Envoy sidecars, traffic management capabilities for intelligent routing (e.g., A/B tests, canary deployments, etc.), and resiliency (timeouts, retries, circuit breakers, etc.)

* <span style="color:orange">**Mixer**</span>
  * Mixer enforces access control and usage policies across the service mesh, and collects telemetry data from the Envoy proxy and other services.

* <span style="color:orange">**Citadel**</span>
  * Citadel provides strong service-to-service and end-user authentication with built-in identity and credential management.

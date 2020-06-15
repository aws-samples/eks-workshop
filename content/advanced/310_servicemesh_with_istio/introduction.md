---
title: "Introduction"
date: 2018-11-13T16:36:24+09:00
weight: 10
draft: false
---

{{% notice info %}}
This chapter has been updated to Istio 1.5.x.
[Click here](https://istio.io/news/releases/1.5.x/announcing-1.5/) to know more about this new release.
{{% /notice %}}

Istio is a completely open source service mesh that layers transparently onto existing distributed applications. It's also a platform, including APIs, that let it integrate into any logging platform, or telemetry or policy system.

Istio works by having a small network proxy sit alongside each microservice called "sidecar".
It's role is to intercept all of the service’s traffic, and handles it more intelligently than a simple layer 3 network can. [Envoy proxy](https://www.envoyproxy.io/) is used as the sidecar and was originally written at Lyft and is now a CNCF project.

An Istio service mesh is logically split into a data plane and a control plane.

* The **data plane** is composed of a set of intelligent proxies (Envoy) deployed as sidecars. These proxies mediate and control all network communication between microservices. They also collect and report telemetry on all mesh traffic.
* The **control plane** manages and configures the proxies to route traffic.

The following diagram shows the different components that make up each plane:

![Istio Architecture](/images/istio/istio_architecture.svg)

* <span style="color:orange">**Envoy Proxy**</span>
  * Processes the inbound/outbound traffic from inter-service and service-to-external-service transparently.

* <span style="color:orange">**Pilot**</span>
  * Pilot provides service discovery for the Envoy sidecars, traffic management capabilities for intelligent routing (e.g., A/B tests, canary deployments, etc.), and resiliency (timeouts, retries, circuit breakers, etc.)

* <span style="color:orange">**Citadel**</span>
  * [Citadel](https://istio.io/docs/concepts/security/) enables strong service-to-service and end-user authentication with built-in identity and credential management.
  
* <span style="color:orange">**Galley**</span>
  * Galley is Istio’s configuration validation, ingestion, processing and distribution component. It is responsible for insulating the rest of the Istio components from the details of obtaining user configuration from the underlying platform (e.g. Kubernetes).

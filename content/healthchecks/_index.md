---
title: "Health Checks"
chapter: true
weight: 61
---

# Health Checks

By default, Kubernetes will restart a container if it crashes for any reason. It uses Liveness and Readiness probes which can be configured for running a robust application by identifying the healthy containers to send traffic to and restarting the ones when required.

In this section, we will understand how [liveness and readiness probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/) are defined and test the same against different states of a pod. Below is the high level description of how these probes work.

**Liveness probes** are used in Kubernetes to know when a pod is alive or dead. A pod can be in a dead state for different reasons while Kubernetes kills and recreates the pod when liveness probe does not pass.

**Readiness probes** are used in Kubernetes to know when a pod is ready to serve traffic. Only when the readiness probe passes, a pod will receive traffic from the service. When readiness probe fails, traffic will not be sent to a pod until it passes.

We will review some examples in this module to understand different options for configuring liveness and readiness probes.

---
title: "Deploying Microservices with a custom Helm Chart"
chapter: true
weight: 80
---

# Deploying Microservices with a custom Helm Chart

![Helm Logo](/images/helm-logo.svg)

[Helm](https://helm.sh/) is a package manager for Kubernetes that packages multiple Kubernetes resources into a single logical deployment unit called **Chart**.

Helm not only is a package manager, but also a Kubernetes application deployment management tool. It helps you to:

- achieve a simple (one command) and repeatable deployment
- manage application dependency, using specific versions of other application and services
- manage multiple deployment configurations: test, staging, production and others
- execute post/pre deployment jobs during application deployment
- update/rollback and test application deployments


In this chapter, we will demonstrate how to deploy microservices using a custom Helm Chart, instead of doing everything manually using `kubectl`.

For detailed information on working with chart templates, refer to the [**Helm docs**](https://docs.helm.sh/chart_template_guide/)

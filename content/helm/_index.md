---
title: "Deploy Helm"
chapter: true
weight: 62
---

In this Chapter, we will deploy [Helm](https://helm.sh/) the Kubernetes Package Manager.

# Kubernetes Helm

![Helm Logo](/images/helm-logo.svg)

[Helm](https://helm.sh/) is a package manager for Kubernetes that packages multiple Kubernetes resources into a single logical deployment unit called **Chart**.

Helm not only is a package manager, but also a Kubernetes application deployment management tool. It helps you to:

- achieve a simple (one command) and repeatable deployment
- manage application dependency, using specific versions of other application and services
- manage multiple deployment configurations: test, staging, production and others
- execute post/pre deployment jobs during application deployment
- update/rollback and test application deployments
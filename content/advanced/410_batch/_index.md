---
title: "Batch Processing with Argo Workflow"
date: 2018-11-18T00:00:00-05:00
weight: 410
draft: false
tags:
  - advanced
  - batch
  - CON205
---

### Batch Processing

In this Chapter, we will deploy common batch processing scenarios using Kubernetes and [Argo](https://argoproj.github.io/).

![Argo Logo](/images/argo-logo.png)

#### What is Argo?
Argo is an open source container-native workflow engine for getting work done on Kubernetes. Argo is implemented as a Kubernetes CRD (Custom Resource Definition).

* Define workflows where each step in the workflow is a container.
* Model multi-step workflows as a sequence of tasks or capture the dependencies between tasks using a graph (DAG).
* Easily run compute intensive jobs for machine learning or data processing in a fraction of the time using Argo workflows on Kubernetes.

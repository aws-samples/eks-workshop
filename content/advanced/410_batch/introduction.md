---
title: "Introduction"
date: 2018-11-18T00:00:00-05:00
weight: 10
draft: false
---

### Introduction

Batch processing refers to performing units of work, referred to as a `job` in a repetitive and unattended fashion. Jobs are typically grouped together and processed in batches (hence the name).

Kubernetes includes native support for [running Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/). Jobs can run multiple pods in parallel until receiving a set number of completions. Each pod can contain multiple containers as a single unit of work.

Argo enhances the batch processing experience by introducing a number of features:

* Steps based declaration of workflows
* Artifact support
* Step level inputs & outputs
* Loops
* Conditionals
* Visualization (using Argo Dashboard)
* ...and more

In this module, we will build a simple Kubernetes Job, recreate that job in Argo, and add common features and workflows for more advanced batch processing.
---
title: "About Helm Charts"
date: 2020-02-18T00:00:00-07:00
weight: 100
---

Helm uses a packaging format called
[Charts](https://helm.sh/docs/topics/charts/).  A Chart is a collection of
files and templates that describes Kubernetes resources.

Charts can be simple, describing something like a standalone web server (which
is what we are going to create).  They can also be more complex: for example,
a chart that represents a full web application stack, including web servers,
databases, proxies, etc.

Instead of installing Kuberetes resources manually via `kubectl`, one can use
Helm to install pre-defined Charts faster, with less chance of typos or other
operator errors.

We will begin by looking through our existing Chart repositories.

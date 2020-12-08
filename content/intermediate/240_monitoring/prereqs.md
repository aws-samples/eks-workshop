---
title: "Prereqs"
date: 2018-10-14T19:56:14-04:00
weight: 5
draft: false
---

#### Is **helm** installed?

We will use **helm** to install Prometheus & Grafana monitoring tools for this chapter. Please review  [installing helm chapter](/beginner/060_helm/helm_intro/install/index.html) for instructions if you don't have it installed.

```bash
# add prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# add grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts
```

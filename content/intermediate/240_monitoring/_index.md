---
title: "Monitoring using Prometheus and Grafana"
date: 2018-10-14T09:27:46-04:00
weight: 240
chapter: true
draft: false
tags:
  - intermediate
  - operations
  - monitoring
  - CON206
---

# Monitoring using Prometheus and Grafana

In this Chapter, we will deploy Prometheus and Grafana to monitor Kubernetes cluster

![grafana-all-nodes](/images/grafana-all-nodes.png)

## What is Prometheus?

[Prometheus](https://prometheus.io/) is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Since its inception in 2012, many companies and organizations have adopted Prometheus, and the project has a very active developer and user community. It is now a standalone open source project and maintained independently of any company. Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

## What is Grafana?

[Grafana](https://grafana.com/) is open source visualization and analytics software. It allows you to query, visualize, alert on, and explore your metrics no matter where they are stored. In plain English, it provides you with tools to turn your time-series database (TSDB) data into beautiful graphs and visualizations.

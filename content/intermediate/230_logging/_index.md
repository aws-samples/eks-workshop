---
title: "Logging with Elasticsearch, Fluentd, and Kibana (EFK)"
chapter: true
weight: 230
tags:
  - advanced
  - operations
  - logging
  - CON206
---

# Implement Logging with EFK

In this Chapter, we will deploy a common Kubernetes logging pattern which consists of the following:

* [Fluentd](https://www.fluentd.org/) is an open source data collector providing a unified logging layer, supported by 500+ plugins connecting to many types of systems.
* [Elasticsearch](https://www.elastic.co/products/elasticsearch) is a distributed, RESTful search and analytics engine.
* [Kibana](https://www.elastic.co/products/kibana) lets you visualize your Elasticsearch data.

Together, Fluentd, Elasticsearch and Kibana is also known as “EFK stack”. Fluentd will forward logs from the individual instances in the cluster to a centralized logging backend (CloudWatch Logs) where they are combined for higher-level reporting using ElasticSearch and Kibana.

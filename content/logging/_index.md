---
title: "Logging with ElasticSearch, Fluentd, and Kibana (EFK)"
chapter: true
weight: 64
---

# Implement Logging with EFK 

In this Chapter, we will deploy a common Kubernetes logging pattern which consists of the following:

1. `Fluentd`is an open source data collector providing a unified logging layer, supported by 500+ plugins connecting to many types of systems.

2. `Elasticsearch` is a distributed, RESTful search and analytics engine.

3. `Kibana` lets you visualize your Elasticsearch data.

Together, Fluentd, Elasticsearch and Kibana is also known as “EFK stack”. Fluentd will forward logs from the individual instances in the cluster to a centralized logging backend (Cloudwatch Logs) where they are combined for higher-level reporting using ElasticSearch and Kibana.

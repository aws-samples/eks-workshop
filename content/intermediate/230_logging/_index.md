---
title: "Logging with Amazon OpenSearch, Fluent Bit, and OpenSearch Dashboards"
chapter: true
weight: 230
tags:
  - intermediate
  - operations
  - logging
  - CON206
---

# Logging with Amazon OpenSearch, Fluent Bit, and OpenSearch Dashboards

In this Chapter, we will deploy a common Kubernetes logging pattern which consists of the following:

* [Fluent Bit](https://fluentbit.io/): an open source and multi-platform Log Processor and Forwarder which allows you to collect data/logs from different sources, unify and send them to multiple destinations. It's fully compatible with Docker and Kubernetes environments.

* [Amazon OpenSearch Service](https://aws.amazon.com/opensearch-service/): OpenSearch is an open source, distributed search and analytics suite derived from Elasticsearch. Amazon OpenSearch Service offers the latest versions of OpenSearch, support for 19 versions of Elasticsearch (1.5 to 7.10 versions), and visualization capabilities powered by OpenSearch Dashboards and Kibana (1.5 to 7.10 versions).

* [OpenSearch Dashboards](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/dashboards.html): OpenSearch Dashboards, the successor to Kibana, is an open-source visualization tool designed to work with OpenSearch. Amazon OpenSearch Service provides an installation of OpenSearch Dashboards with every OpenSearch Service domain.

Fluent Bit will forward logs from the individual instances in the cluster to a centralized logging backend where they are combined for higher-level reporting using Amazon OpenSearch Service .

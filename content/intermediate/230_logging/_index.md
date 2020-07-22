---
title: "Logging with Elasticsearch, Fluent Bit, and Kibana (EFK)"
chapter: true
weight: 230
tags:
  - intermediate
  - operations
  - logging
  - CON206
---

# Implement Logging with EFK

In this Chapter, we will deploy a common Kubernetes logging pattern which consists of the following:

* [Fluent Bit](https://fluentbit.io/): an open source and multi-platform Log Processor and Forwarder which allows you to collect data/logs from different sources, unify and send them to multiple destinations. It's fully compatible with Docker and Kubernetes environments.

* [Amazon Elasticsearch Service](https://aws.amazon.com/elasticsearch-service/): a fully managed service that makes it easy for you to deploy, secure, and run [Elasticsearch](https://www.elastic.co/what-is/elasticsearch) cost effectively at scale.

* [Kibana](https://www.elastic.co/what-is/kibana): an open source frontend application that sits on top of the Elasticsearch, providing search and data visualization capabilities for data indexed in Elasticsearch.

Together, Fluent Bit, Elasticsearch and Kibana is also known as "EFK stack".

Fluent Bit will forward logs from the individual instances in the cluster to a centralized logging backend where they are combined for higher-level reporting using ElasticSearch and Kibana.

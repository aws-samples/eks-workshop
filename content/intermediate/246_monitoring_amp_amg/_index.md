---
title: "Monitoring using Amazon Managed Service for Prometheus / Grafana"
date: 2018-10-14T09:27:46-04:00
weight: 246
chapter: true
draft: false
tags:
  - intermediate
  - operations
  - monitoring
  - AMP
  - AMG
  - Amazon Managed Service for Prometheus
  - Amazon Managed Service for Grafana

---
### Introduction
#### Amazon Managed Service for Prometheus (AMP) 
Amazon Managed Service for Prometheus is a monitoring service for metrics compatible with the open source Prometheus project, making it easier for you to securely monitor container environments. AMP is a solution for monitoring containers based on the popular Cloud Native Computing Foundation (CNCF) Prometheus project. AMP is powered by Cortex, an open source CNCF project that adds horizontal scalability to ingest, store, query, and alert on Prometheus metrics. AMP reduces the heavy lifting required to get started with monitoring applications across Amazon Elastic Kubernetes Service and Amazon Elastic Container Service, as well as self-managed Kubernetes clusters. AMP automatically scales as your monitoring needs grow. It offers highly available, multi-Availability Zone deployments, and integrates AWS security and compliance capabilities. AMP offers native support for the PromQL query language as well as over 150+ Prometheus exporters maintained by the open source community.


{{% button href="https://aws.amazon.com/prometheus/faqs/" icon="fab fa-leanpub" icon="fab fa-leanpub" icon-position="right"  %}}Learn more about AMP{{% /button %}}



#### Amazon Managed Service for Grafana (AMG)

Amazon Managed Service for Grafana is a fully managed service with rich, interactive data visualizations to help customers analyze, monitor, and alarm on metrics, logs, and traces across multiple data sources. You can create interactive dashboards and share them with anyone in your organization with an automatically scaled, highly available, and enterprise-secure service. With Amazon Managed Service for Grafana, you can manage user and team access to dashboards across AWS accounts, AWS regions, and data sources. Amazon Managed Service for Grafana provides an intuitive resource discovery experience to help you easily onboard your AWS accounts across multiple regions and securely access AWS services such as Amazon CloudWatch, AWS X-Ray, Amazon Elasticsearch Service, Amazon Timestream, AWS IoT SiteWise, and Amazon Managed Service for Prometheus.


{{% button href="https://aws.amazon.com/grafana/faqs/" icon="fab fa-leanpub" icon="fab fa-leanpub" icon-position="right"  %}}Learn more about AMG{{% /button %}}
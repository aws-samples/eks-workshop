---
title: "Monitoring using Amazon Managed Service for Prometheus / Grafana"
date: 2018-10-14T09:27:46-04:00
weight: 280
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
{{% notice info%}}
This service is currently in preview and not available on Event Engine.
{{% /notice %}}
{{%youtube Bh71xBQe92I%}}

<br>

Amazon Managed Service for Prometheus is a monitoring service for metrics compatible with the open source Prometheus project, making it easier for you to securely monitor container environments. AMP is a solution for monitoring containers based on the popular Cloud Native Computing Foundation (CNCF) Prometheus project. AMP is powered by Cortex, an open source CNCF project that adds horizontal scalability to ingest, store, query, and alert on Prometheus metrics. AMP reduces the heavy lifting required to get started with monitoring applications across Amazon Elastic Kubernetes Service and Amazon Elastic Container Service, as well as self-managed Kubernetes clusters. AMP automatically scales as your monitoring needs grow. It offers highly available, multi-Availability Zone deployments, and integrates AWS security and compliance capabilities. AMP offers native support for the PromQL query language as well as over 150+ Prometheus exporters maintained by the open source community.

{{% button href="https://aws.amazon.com/prometheus/faqs/" icon="fab fa-leanpub" icon="fab fa-leanpub" icon-position="right"  %}}Learn more about this topic...{{% /button %}}






#### Amazon Managed Service for Grafana (AMG)

{{%youtube Bh71xBQe92I%}}

Amazon Managed Service for Grafana (AMG) is a fully managed and secure data visualization service that enables customers to instantly query, correlate, and visualize operational metrics, logs, and traces for their applications from multiple data sources. AMG is based on the open source Grafana project, a widely deployed data visualization tool popular for its extensible data source support. Developed together with Grafana Labs, AMG manages the provisioning, setup, scaling, and maintenance of Grafana, eliminating the need for customers to do this themselves. Customers also benefit from built-in security features that enable compliance with governance requirements, including single sign-on, fine-grained data access control, and audit reporting. AMG is integrated with AWS data sources that collect operational data, such as Amazon CloudWatch, Amazon Elasticsearch Service, Amazon Timestream, AWS IoT SiteWise, AWS X-Ray, and Amazon Managed Service for Prometheus (AMP), and provides plug-ins to popular open-source databases, third-party ISV monitoring tools, as well as other cloud services. With AMG you can easily visualize information from multiple AWS services, AWS accounts, and Regions in a single Grafana dashboard.

{{% button href="https://aws.amazon.com/grafana/faqs/" icon="fab fa-leanpub" icon="fab fa-leanpub" icon-position="right"  %}}Learn more about this topic...{{% /button %}}
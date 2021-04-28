---
title: "Observability"
date: 2020-01-27T08:30:11-07:00
weight: 90
draft: false
---

In this chapter, we will dive into key operational data and tools such as CloudWatch Container Insights, Cloudwatch Logs and Prometheus that you can leverage within the AWS environment to supercharge your ability to monitor metrics, collect logs, trigger alerts, and trace distributed services.

Observability includes the use of various signals (metrics, traces, logs) to monitor the overall health of your application. And in this section, we'll use the following data and tools to get the end to end vissibility into our Product Catalog Application deployed in EKS.

* Container Insights
* Cloudwatch Container logs
* Prometheus App Mesh Metrics
* Fargate Container logs
* AWS X-Ray Tracing

{{% notice info %}}
Make sure that you have completed the [Observability Setup](/advanced/330_servicemesh_using_appmesh/add_nodegroup_fargate/cloudwatch_setup/) chapter before proceeding to the next section. {{% /notice %}}

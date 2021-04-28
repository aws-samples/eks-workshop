---
title: "EKS CloudWatch Container Insights"
chapter: true
weight: 250
tags:
  - intermediate
  - operations
  - monitoring
  - CON206
---

In this chapter we will learn and leverage the new CloudWatch Container Insights to see how you can use native CloudWatch features to monitor your EKS Cluster performance.

You can use CloudWatch Container Insights to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. Container Insights is available for Amazon Elastic Container Service, Amazon Elastic Kubernetes Service, and Kubernetes platforms on Amazon EC2. The metrics include utilization for resources such as CPU, memory, disk, and network. Container Insights also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly.

{{% notice note %}}
In order to complete this lab you will need to have a working EKS Cluster, With `Helm` installed.
You will need to have completed the [Start the Workshop...](/020_prerequisites/) through  [Launching your cluster with Eksctl](/030_eksctl/) and [Install Helm CLI](/beginner/060_helm/helm_intro/install/) as well.
{{% /notice %}}

{{% notice tip%}}
To learn all about our Observability features using Amazon CloudWatch and AWS X-Ray, take a look at our [One Observability Workshop](https://observability.workshop.aws)
{{% /notice%}}

![alt text](/images/ekscwci/insights.png "CW Insights")

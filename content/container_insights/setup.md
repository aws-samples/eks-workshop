---
title: "Setup Container Insights"
chapter: false
weight: 1
---

There are 2 components that work together to collect Metrics, Logs data for Container Insights in EKS

1. CloudWatch agent
2. FluentD

#### Demo App
In this section we will be setting up Container Insights for the ECS Demo app that you created in the *Deploy the Example Microservices* section earlier. If you haven't done that yet, go ahead and deploy the application and come back here again to proceed with Container Insights.

#### Prerequisites
Before you proceed further make sure the prerequisites mentioned in this link are taken care of

* https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html

------------------------------------------------------------

#### Option 1
#### Quick start setup

Follow the quickstart setup for Container Insights on EKS easily in one easy step. This is the fastest way to setup CloudWatch Container Insights for your cluster. If you want to take a step by step approach to understand clearly, skip this step and go to instructions under Option 2.

* https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html

------------------------------------------------------------

#### Option 2
#### CloudWatch agent
##### Set Up the CloudWatch Agent to Collect Cluster Metrics

The CloudWatch agent needs to be setup as a DaemonSet which will then collect metrics and send to CloudWatch. Optionally, you could also collect application generated custom metrics using StatsD ([What is StatsD?] (https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-custom-metrics-statsd.html)) protocol.

Follow these instructions to setup CloudWatch agent as a DaemonSet

* https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-metrics.html


#### FluentD
##### Set Up FluentD as a DaemonSet to Send Logs to CloudWatch Logs

FluentD ([What is FluentD?](https://www.fluentd.org/)) allows you to collect application logs from your containers and send them to CloudWatch

Follow these instructions to setup FluentD as a DaemonSet in your EKS cluster

* https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs.html 

{{% children showhidden="false" %}}

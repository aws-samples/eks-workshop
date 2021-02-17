---
title: "Prometheus Metrics"
date: 2020-01-27T08:30:11-07:00
weight: 94
draft: false
---
CloudWatch Container Insights monitoring for Prometheus automates the discovery of Prometheus metrics from containerized systems and workloads. Prometheus is an open-source systems monitoring and alerting toolkit. 

#### Prometheus Metrics Logs
The CloudWatch agent supports the standard Prometheus scrape configurations as documented in [scrape_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) in the Prometheus documentation. 
The CloudWatch agent YAML that we set up in the chapter [enable-prometheus-metrics-in-cloudwatch](/advanced/330_servicemesh_using_appmesh/add_nodegroup_fargate/create_nodegroup/#enable-prometheus-metrics-in-cloudwatch) have jobs configured that are scraped, and the metrics are sent to CloudWatch.

Log events from Amazon EKS and Kubernetes clusters are stored in the /aws/containerinsights/cluster_name/prometheus LogGroup in Amazon CloudWatch Logs.

Log into console, navigate to Cloudwatch -> LogGroups, you should see `/aws/containerinsights/eksworkshop-eksctl/prometheus` LogGroup, select this and you should be able to see the metrics for all the containers logged here. 
![\[Image NOT FOUND\]](/images/app_mesh_fargate/prometheus-logs.png)

#### Prometheus Metrics
The CloudWatch agent with Prometheus support automatically collects metrics from services and workloads. Prometheus metrics collected from Amazon EKS and Kubernetes clusters are in the `ContainerInsights/Prometheus` namespace.

Log into console, navigate to Cloudwatch ->  Metrics -> ContainerInsights/Prometheus -> "ClusterName, Namespace" , you should see the below metrics for the namespace `prodcatalog-ns`. 
Select any of the metrics (as in below example `envoy_cluster_upstream_cx_rx_bytes_total`) to add to the graph. You can find the complete list of Prometheus Metrics for App Mesh [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus-metrics.html#ContainerInsights-Prometheus-metrics-appmesh).
![\[Image NOT FOUND\]](/images/app_mesh_fargate/prometheus-metrics.png)


#### Prometheus Report
In the CloudWatch console, Container Insights provides pre-built reports for App Mesh in Amazon EKS and Kubernetes clusters.

To see the pre-built reports on App Mesh Prometheus metrics, Log into console, navigate to Cloudwatch -> "Performance monitoring" -> "Container Insights", select `EKS Prometheus App Mesh` in first dropdown and select the `EKS cluster` in second dropdown.
![\[Image NOT FOUND\]](/images/app_mesh_fargate/prometheus-reports.png)

![\[Image NOT FOUND\]](/images/app_mesh_fargate/prometheus-reports2.png)
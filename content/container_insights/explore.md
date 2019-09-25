---
title: "Explore Container Insights"
chapter: false
weight: 2
---

* Once the setup steps are complete, logon to AWS console and navigate to AWS CloudWatch home page. Select *Container Insights* from the drop down on the home page as shown below

![Container Insights](/images/ContainerInsights1.png)

* Ensure *EKS Clusters* is selected in the first dropdown and select the name of your EKS cluster in the second dropdown. You will be able to see several build-in charts showing various cluster level metrics such as CPU Utilization, Memory Usage, Disk Usage, Network and so on in the default dashboard as shown below

![Container Insights](/images/ContainerInsights2.png)

* You can also view Performance Logs, Application Logs, Control Plane Logs ([when enabled](https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-control-plane-logging.html)), Data Plane Logs and Host Logs by simply selecting the cluster name and clicking on Actions dropdown as shown below

![Container Insights](/images/ContainerInsights3.png)

* You can also drill down into the cluster and see the metrics at the Pod level by simply selecting *EKS Pods* in the first drop down as shown below

![Container Insights](/images/ContainerInsights5.png)

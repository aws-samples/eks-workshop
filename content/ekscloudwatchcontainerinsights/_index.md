---
title: "EKS Cloud Watch Container Insights"
chapter: true
weight: 51
---

In this chapter we will learn and leverage the new CloudWatch Container Insights to see how you can use native CloudWatch features to monitor your EKS Cluster performance.

You can use CloudWatch Container Insights to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. Container Insights is available for Amazon Elastic Container Service, Amazon Elastic Kubernetes Service, and Kubernetes platforms on Amazon EC2. The metrics include utilization for resources such as CPU, memory, disk, and network. Container Insights also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly.
 
In order to complete this lab you will need to have a working EKS Cluster, With Helm installed and deployed. 

You will need to have completed the <a href="https://eksworkshop.com/prerequisites/">Start the Workshop..</a> thorugh <a href="https://eksworkshop.com/eksctl/"> Launching your cluster with Eksctl</a> and the <a href="https://eksworkshop.com/helm_root/"> install of Helm </a> as well. 


<img src="/ekscloudwatchcontainerinsights/img/insights.png">
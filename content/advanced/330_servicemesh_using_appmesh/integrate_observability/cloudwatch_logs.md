---
title: "Cloudwatch Logs"
date: 2020-01-27T08:30:11-07:00
weight: 92
draft: false
---

#### Cloudwatch Console

Logs are collected by the fluentd daemonset running in the EKS nodes and also by Fluentbit daemonset that collect logs from Fargate and send them to Cloudwatch. 

The following CloudWatch log groups are created by default when Container Insights is setup:

* /aws/containerinsights/cluster-name/application
* /aws/containerinsights/cluster-name/dataplane
* /aws/containerinsights/cluster-name/hostNodegroup Container Logs
* /aws/containerinsights/cluster-name/performance
* /aws/eks/eksworkshop-eksctl/cluster
* fluent-bit-cloudwatch

Log into console, navigate to Cloudwatch -> LogGroups, you should see below log groups
![\[Image NOT FOUND\]](/images/app_mesh_fargate/log1.png)

#### Nodegroup Container Logs
Click on the `application` LogGroup, and click on `Search All`
![\[Image NOT FOUND\]](/images/app_mesh_fargate/search1.png)

Now, Type `Catalog Detail Version` in the Search box and Click enter, you should see the below logs from `proddetail` backend service
![\[Image NOT FOUND\]](/images/app_mesh_fargate/product-v1-1.png)

#### Fargate Container Logs
Log into console, navigate to Cloudwatch -> LogGroups -> Click on `fluent-bit-cloudwatch` LogGroup -> Click on `Search All` and type `Get Request succeeded` in the search box and enter, you should see below logs
![\[Image NOT FOUND\]](/images/app_mesh_fargate/fargate_log.png)

#### (Optional) Control Plane Logging
If you want to enable control plane logging, follow this [link](/advanced/330_servicemesh_using_appmesh/add_nodegroup_fargate/create_nodegroup/#enable-control-plane-logs-optional)

Then, Log into console, navigate to Cloudwatch -> LogGroups, you should see log group `/aws/eks/eksworkshop-eksctl/cluster` for Control Plane as below
![\[Image NOT FOUND\]](/images/app_mesh_fargate/controlplanelog.png)

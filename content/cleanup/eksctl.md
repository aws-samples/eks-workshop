---
title: "Delete the EKSCTL Cluster"
date: 2018-08-07T13:37:53-07:00
weight: 30
---

In order to delete the resources created for this EKS cluster, run the following commands:

Delete the cluster:
```
eksctl delete cluster --name=eksworkshop-eksctl
```

{{% notice tip %}}
The nodegroup will have to complete the deletion process before the EKS cluster
can be deleted. The total process will take approximately 15 minutes, and can be monitored via the
[CloudFormation Console](https://console.aws.amazon.com/cloudformation/home)
{{% /notice %}}

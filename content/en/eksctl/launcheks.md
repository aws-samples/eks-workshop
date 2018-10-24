---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---

To create a basic EKS cluster, run:
```
eksctl create cluster --name=eksworkshop-eksctl --nodes=3 --node-ami=auto --region=${AWS_REGION}
```
{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}

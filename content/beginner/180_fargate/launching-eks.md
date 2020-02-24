---
title: "Creating/Preparing a Cluster for Deployment with Fargate"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

AWS Fargate with Amazon EKS is currently only available in the following Regions: us-east-1, us-east-2, ap-northeast-1, eu-west-1. Pods running on Fargate are supported on  EKS clusters beginning with Kubernetes version 1.14 and platform version eks.5. 

If you have already setup an EKS cluster with worker nodes by following instructions in the Chapter [Launch using eksctl](https://eksworkshop.com/030_eksctl/), you may continue to work with the same cluster in this Chapter and skip to the next step.

<b>If you do not already have an EKS cluster</b>, then first follow the instructions under [Prerequisites](https://eksworkshop.com/030_eksctl/prerequisites/) and install the [eksctl](http://eksctl.io) utility. Then, create an EKS cluster that supports Fargate with the following command:

#### Create an EKS cluster supporting Fargate
```
eksctl create cluster --name=eksworkshop-eksctl --alb-ingress-access --region=${AWS_REGION} --fargate
```
{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}

This command will provision a serverless EKS cluster as well as create a default Fargate profile that maps all the pods in the <b>kube-system</b> and <b>default</b> namespaces to Fargate. If you are working with an existing EKS cluster that contains managed worker nodes, the pods that belong in the <b>kube-system</b> and <b>default</b> namespaces will have been already deployed on those worker nodes. Hence, there is no need to change that setup. Just be aware that if you had created a serverless cluster from scratch using the above command, then you would have had all those pods deployed under Fargate.
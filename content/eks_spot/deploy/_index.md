---
title: "Deploying the example Microservice"
chapter: true
weight: 50
---

# Deploying the example Microservice

To illustrate application scaling using [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (HPA) and cluster scaling using [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) (CA), we will deploy a microservice that generates CPU load.

The microservice we will use as an example, is a trivial web service that uses a [Monte Carlo method to approximate pi](https://en.wikipedia.org/wiki/Monte_Carlo_integration) written in go. You can find the application code in in [this github repo](https://github.com/ruecarlo/eks-workshop-sample-api-service-go)

![Monte Carlo Pi Approximation](/images/using_ec2_spot_instances_with_eks/deploy/monte_carlo_pi.png)
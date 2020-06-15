---
title: "Securing Your Cluster with Network Policies"
chapter: true
weight: 120
tags:
  - intermediate
---

# Securing your cluster with network policies

In this chapter, we are going to use two tools to secure our cluster by using network policies and then integrating our cluster's network policies with EKS security groups.

First we will use [Project Calico](https://www.projectcalico.org) to enforce Kubernetes network policies in our cluster, protecting our various microservices.

After that, we will use [Tigera's](https://www.tigera.io) [Secure Cloud Edition](https://www.tigera.io/tigera-secure-ce) to integrate the Kubernetes network policies with Amazon's VPC security groups.


![calico](/images/Project-Calico-logo-1000px.png)

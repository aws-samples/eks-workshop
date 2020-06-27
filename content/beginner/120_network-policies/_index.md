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

After that, we will use [Calico Enterprise](https://www.tigera.io/tigera-products/calico-enterprise) to
- Implement Egress Access Controls to enable your EKS workloads to communicate with other Amazon services (for example: RDS or EC2 instances) or other API endpoints.
- Troubleshoot microservices that are unable to communicate with each other
- Implement and report on Enterprise Security Controls in EKS

![calico](/images/Project-Calico-logo-1000px.png)

![calico Enterprise](/images/Calico-enterprise-logo-1000px.png)

---
title: "EMR on EKS"
date: 2021-03-15T12:30:45-04:00
weight: 430
chapter: true
aliases:
    - /emr_on_eks/
tags:
  - advanced
  - emr on eks
  - spark
---
# [EMR on EKS](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/emr-eks.html)

[EMR on EKS](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/emr-eks.html) is a deployment option in EMR that allows you to automate the provisioning and management of open-source big data frameworks on EKS. There are several advantages of running optimized spark runtime provided by Amazon EMR on EKS such as [3x faster performance](https://aws.amazon.com/emr/faqs/), fully managed lifecycle of these jobs, built-in monitoring and logging functionality, integrates securely with Kubernetes and more. Because Kubernetes can natively run Spark jobs, if you use multi-tenant EKS environment (shared with other micro-services), your spark jobs are deployed in seconds vs minutes when compared to EC2 based deployments.

In this module, we will review how to setup your EKS cluster and run a sample spark job, setup monitoring and logging for these jobs, configure autoscaling, use Kubernetes node selectors for jobs that need to meet certain constraints such as run in single-az, use spot best practices for running EMR on EKS, and use the serverless compute engine AWS Fargate with Amazon EKS to support EMR workloads.

For more hands-on labs, see the dedicated [EMR on EKS Workshop](https://emr-on-eks.workshop.aws/).

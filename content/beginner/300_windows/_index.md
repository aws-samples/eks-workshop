---
title: "Windows containers on EKS"
date: 2020-07-27T11:33:21-04:00
draft: false
chapter: true
tags:
  - beginner
---

# Windows containers on EKS

Many development teams build and support applications designed to run on Windows Servers and with [Windows Container Support on EKS](https://aws.amazon.com/blogs/aws/amazon-eks-windows-container-support-now-generally-available/), they can now deploy them on Kubernetes alongside Linux applications. This ability will provide more consistency in system logging, performance monitoring, and code deployment pipelines.

To demonstrate how this feature works, you will add a new node group which contains 2 Windows servers 2019 to our EKS Cluster and deploy a Windows application. Finally, you will test the application to ensure it is running as expected.

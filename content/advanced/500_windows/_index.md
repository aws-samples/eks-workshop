---
title: "Windows containers on EKS"
date: 2020-07-27T11:33:21-04:00
draft: false
chapter: true
---

# Windows containers on EKS

Many development teams build and support applications designed to run on Windows Servers and with Windows Container Support on EKS, they can now deploy them on Kubernetes alongside Linux applications. This ability will provide more consistency in system logging, performance monitoring, and code deployment pipelines.

**FIX ME**
To show you how this feature works, I will need an Amazon Elastic Kubernetes Service cluster. I am going to create a new one, but this will work with any cluster that is using Kubernetes version 1.14 and above. Once the cluster has been configured, I will add some new Windows nodes and deploy a Windows application. Finally, I will test the application to ensure it is running as expected.


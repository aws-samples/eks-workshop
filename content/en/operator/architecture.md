---
title: "What We'll Be Making"
date: 2018-08-07T08:30:11-07:00
weight: 1
draft: true
---

We're going to deploy a simple multi-tier microservice application. This will
use an S3 Bucket to serve static assets from, a Kubernetes Job to hydrate the
bucket with assets and then a backend application which reads and writes from
DynamoDB.

![Architecture Diagram](/images/aws-operator-demo.png)

---
title: "Deploy Product Catalog app"
date: 2018-11-13T16:32:30+09:00
weight: 20
draft: false
---

To understand `AWS App Mesh`, its best to also understand any applications that run on top of it. In this chapter, we'll walk you through the following parts of application setup and deployment:

+ Discuss the Application Architecture
+ Build the Application Services [container](https://docs.docker.com/engine/reference/commandline/images/) images
+ Push the container images to [Amazon ECR](https://aws.amazon.com/ecr/) 
+ Deploy the application services into the [Amazon EKS](https://aws.amazon.com/eks/) cluster, initially **without** AWS App Mesh.
+ Test the connectivity between the Services
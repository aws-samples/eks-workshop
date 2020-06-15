---
title: "CI/CD with CodePipeline"
chapter: true
weight: 220
draft: false
tags:
  - advanced
  - operations
  - ci/cd
  - CON205
---

# CI/CD with CodePipeline

[Continuous integration](https://aws.amazon.com/devops/continuous-integration/) (CI) and [continuous delivery](https://aws.amazon.com/devops/continuous-delivery/) (CD)
are essential for deft organizations. Teams are more productive when they can make discrete changes frequently, release those changes programmatically and deliver updates
without disruption.

In this module, we will build a CI/CD pipeline using [AWS CodePipeline](https://aws.amazon.com/codepipeline/). The CI/CD pipeline will deploy a sample Kubernetes service,
we will make a change to the GitHub repository and observe the automated delivery of this change to the cluster.

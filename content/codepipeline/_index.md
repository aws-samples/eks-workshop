---
title: "CI/CD with CodePipeline"
chapter: true
weight: 42
draft: false
---

# CI/CD with CodePipeline

{{% notice warning %}}
This chapter does not work in the AWS supplied event environments yet. If you are
**at an AWS event**, please skip this chapter. If you are working in your own account,
you should have no issues.
{{% /notice %}}

[Continuous integration](https://aws.amazon.com/devops/continuous-integration/) (CI) and [continuous delivery](https://aws.amazon.com/devops/continuous-delivery/) (CD)
are essential for deft organizations. Teams are more productive when they can make discrete changes frequently, release those changes programmatically and deliver updates
without disruption.

In this module, we will build a CI/CD pipeline using [AWS CodePipeline](https://aws.amazon.com/codepipeline/). The CI/CD pipeline will deploy a sample Kubernetes service,
we will make a change to the GitHub repository and observe the automated delivery of this change to the cluster.

---
title: "GitOps with Weave Flux"
chapter: true
weight: 260
draft: false
tags:
  - advanced
  - operations
  - ci/cd
  - gitops
---

# GitOps with Weave Flux

[GitOps](https://www.weave.works/technologies/gitops/), a term coined by [Weaveworks](https://www.weave.works/), is a way to do [continuous delivery](https://aws.amazon.com/devops/continuous-delivery/).  Git is used as single source of truth for deploying into your cluster.  This is easy for a development team as they are already familiar with git and do not need to know other tools.  [Weave Flux](https://www.weave.works/oss/flux/) is a tool that runs in your Kubernetes cluster and implements changes based on monitoring Git and image repositories.

In this module, we will create a Docker image build pipeline using [AWS CodePipeline](https://aws.amazon.com/codepipeline/) for a sample application in a [GitHub](https://github.com/) repository. We will then commit Kubernetes manifests to GitHub and monitor Weave Flux managing the deployment.

Below is a diagram of what will be created:

![GitOps Workflow](/images/weave_flux/gitops_workflow.png)

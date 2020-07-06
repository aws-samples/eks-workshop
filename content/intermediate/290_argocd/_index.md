---
title: "Continuous Deployment with ArgoCD"
chapter: true
weight: 260
draft: false
tags:
  - intermediate
  - cd
  - gitops
---

# Continuous Deployment with ArgoCD
[Argo CD] (https://argoproj.github.io/argo-cd/) is a declarative, GitOps continuous delivery tool for Kubernetes. 
The core component of Argo CD is the Application Controller, which continuously monitors running applications and compares the live application state against the desired target state defined in the Git repository. This powers the following use cases:

**Automated deployment** : controller pushes the desired application state into the cluster automatically, either in response to a Git commit, a trigger from CI pipeline, or a manual user request.

**Observability** : developers can quickly find if the application state is in sync with the desired state. Argo CD comes with a UI and CLI which helps to quickly inspect the application and find differences between the desired and the current live state.

**Operation** : Argo CD UI visualizes the entire application resource hierarchy, not just top-level resources defined in the Git repo. For example, developers can see ReplicaSets and Pods produced by the Deployment defined in Git. From the UI, you can quickly see Pod logs and the corresponding Kubernetes events. This turns Argo CD into very powerful multi-cluster dashboard.

![Argo Logo](/images/argo-logo.png)



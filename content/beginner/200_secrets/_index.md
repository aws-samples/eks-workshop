---
title: "Managing Secrets Deployment"
chapter: true
weight: 200
tags:
  - beginner
  - CON206
---

# Managing Secrets Deployment

[Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/) is a resource that helps cluster operators manage the deployment of sensitive information such as sensitive information, such as passwords, OAuth tokens, and ssh keys etc. These Secrets can be mounted as data volumes or exposed as environment variables to the containers in a Pod, thus decoupling Pod deployment from managing sensitive data needed by the containerized applications within a Pod. 

It is a common practice for a DevOps Team to manage the YAML manifests for various Kubernetes resources and version control them using a Git repository. Additionally, they can integrate a Git repository with a [GitOps workflow to do Continuous Delivery](https://eksworkshop.com/intermediate/260_weave_flux/) of such resources to an EKS cluster. The challenge here is about managing the YAML manifests for Kubernetes Secrets outside the cluster. The sesitive data in a Secret is obfuscated by using merely base64 encoding. Storing such files in a Git repository is extremely insecure as it is trivial to decode the base64 encoded data. 

In this Chapter, you will implement a solution that enables you to encrypt these YAML manifests so that they are safe to store, even to a public repository, and also be able deploy these encrypted Secrets to your EKS clusters using normal workflows with tools such as [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/).

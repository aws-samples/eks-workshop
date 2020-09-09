---
title: "Using Open Policy Agent (OPA) for policy-based control in EKS"
chapter: true
weight: 300
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
draft: false
tags:
  - intermediate
  - open policy agent
  - opa
---

# Using Open Policy Agent (OPA) for policy-based control in EKS

{{< youtube Lez1c2K8r1o >}}

Security and governance is a critical component of configuring and managing fine-grained control for Kubernetes clusters and applications. Amazon EKS provides secure, managed Kubernetes clusters by default, but you still need to ensure that you configure and administer the applications appropriately that you run as part of the cluster. 

The Open Policy Agent (OPA, pronounced “oh-pa”) is an open source, general-purpose policy engine that unifies policy enforcement across the stack. OPA provides a high-level declarative language that let’s you specify policy as code and simple APIs to offload policy decision-making from your software.

- AWS Blogs on OPA:
[Using Open Policy Agent on Amazon EKS](https://aws.amazon.com/blogs/opensource/using-open-policy-agent-on-amazon-eks/)
[Realize Policy-as-Code with AWS Cloud Development Kit through Open Policy Agent](https://aws.amazon.com/blogs/opensource/realize-policy-as-code-with-aws-cloud-development-kit-through-open-policy-agent/)
[OCI Artifact Support in Amazon ECR](https://aws.amazon.com/blogs/containers/oci-artifact-support-in-amazon-ecr/)


In this chapter, we take a look at how to implement OPA on an Amazon EKS cluster and take a look at a scenario to restrict container images from an approved ECR repository using a OPA policy.
---
title: "Service Mesh with Tetrate Istio Distro via EKS Addon"
date: 2018-11-13T16:32:30+09:00
weight: 320
draft: false
tags:
  - advanced
  - operations
  - servicemesh
  - tetrate-istio-distro
  - tetrate
  - tid
  - eks-add-on
---

Tetrate Istio Distro is an open source project from Tetrate that provides vetted builds of Istio tested against all major cloud platforms. TID provides extended Istio version support beyond upstream Istio (release date plus 14 months).

The TID Istio distributions are hardened and performant, and are full distributions of the upstream Istio project. The detailed information can be found here - on the [dedicated website](https://tetratelabs.io/introduction/)

[Amazon EKS add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) provide installation and management of a curated set of add-ons for Amazon EKS clusters. All Amazon EKS add-ons include the latest security patches, bug fixes, and are validated by AWS to work with Amazon EKS.

Tetrate Istio Distro has been added to the list of supported add-ons since the lunch EKS add-ons and allows Istio deployment on EKS cluster in matter of minutes.

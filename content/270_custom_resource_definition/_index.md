---
title: "Custom Resource Definition"
chapter: true
weight: 270
tags:
  - advanced
  - operations
  - crd
---

# Custom Resource Definition
### Introduction

In this Chapter, we will review the Custom Resource Definition (CRD) concept, and some examples of usage.

In Kubernetes API, a resource is an endpoint storing the API objects in a collection.
As an example, the pods resource contains a collection of Pod objects.

CRD’s are extensions of Kubernetes API that stores collection of API objects of certain kind. They extend the Kubernetes API or allow you to add your own API into the cluster.

To create a CRD, you need to create a file, that defines your object kinds and lets the API Server manage the lifecycle. Applying a CRD into the cluster makes the Kubernetes API server to serve the specified custom resource.

When a CRD is created, the Kubernetes API creates a new RESTful resource path, that can be accesed by a cluster or a single namespace.

---
title: "Kubernetes Nodes"
date: 2018-10-03T10:15:55-07:00
draft: true
weight: 40
---

The machines that make up a Kubernetes cluster are called **nodes**.

Nodes in a Kubernetes cluster may be physical, or virtual.  

There are two types of nodes:

* Master-node type, which makes up the Control Plane, acts as the “brains” of the cluster.

* A Worker-node type, which makes up the Data Plane, runs the actual container images (via pods.)

We’ll dive deeper into how nodes interact with each other later in the presentation.

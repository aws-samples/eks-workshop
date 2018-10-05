---
title: "K8s Objects Overview"
date: 2018-10-03T10:15:55-07:00
draft: false
weight: 50
---

Kubernetes objects are entities that are used to represent the state of the cluster.  

An object is a “record of intent” – once created, the cluster does its best to ensure it exists as defined.  This is known as the cluster’s “desired state.”

Kubernetes is always working to make an object’s “current state” equal to the object’s “desired state.”  A desired state can describe:

* What pods (containers) are running, and on which nodes
* IP endpoints that map to a logical group of containers
* How many replicas of a container are running
* And much more...

Let’s explain these k8s objects in a bit more detail...

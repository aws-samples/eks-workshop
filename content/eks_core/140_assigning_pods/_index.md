---
title: "Assigning Pods to Nodes"
chapter: true
weight: 140
tags:
  - intermediate
  - CON203
---

# Assigning Pods to Nodes
### Introduction

In this Chapter, we will review how the strategy of assigning Pods works, alternatives and recommended approaches.

You can constrain a pod to only be able to run on particular nodes or to prefer to run on particular nodes.

Generally such constraints are unnecessary, as the scheduler will automatically do a reasonable placement (e.g. spread your pods across nodes, not place the pod on a node with insufficient free resources, etc.) but there are some circumstances where you may want more
control on a node where a pod lands, e.g. to ensure that a pod ends up on a machine with an SSD attached to it, or to co-locate pods from two different services that communicate a lot into the same availability zone.

---
title: "Ingress Controller"
date: 2019-04-09T00:00:00-03:00
weight: 14
draft: false
---

#### Ingress Controllers
In order for the Ingress resource to work, the cluster must have an ingress controller running.

Unlike other types of controllers which run as part of the kube-controller-manager binary, Ingress controllers are not started automatically with a cluster. Let's see some options:


---
title: "Data Plane Detail"
date: 2018-10-03T10:18:27-07:00
draft: true
weight: 110
---

<img src=/images/introduction/architecture_worker_compact.png width=250>

* Made up of worker nodes

* kubelet: Acts as a conduit between the API server and the node

* kube-proxy: Manages IP translation and routing

Check out [the official Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/components/#node-components) for a more in-depth explanation of data plane components.

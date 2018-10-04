---
title: "Control Plane Detail"
date: 2018-10-03T10:18:27-07:00
draft: true
weight: 100
---

![k8s control plane](/images/introduction/architecture_control.png)

* One or More API Servers: Entry point for REST / kubectl

* etcd: Distributed key/value store

* Controller-manager: Always evaluating current vs desired state

* Scheduler: Schedules pods to worker nodes

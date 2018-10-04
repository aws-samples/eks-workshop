---
title: "Control Plane Detail"
date: 2018-10-03T10:18:27-07:00
draft: true
weight: 100
---

<img src=/images/basic_concepts/architecture_control.png width=350>

* One or More API Servers: Entry point for REST / kubectl

* etcd: Distributed key/value store

* Controller-manager: Always evaluating current vs desired state

* Scheduler: Schedules pods to worker nodes

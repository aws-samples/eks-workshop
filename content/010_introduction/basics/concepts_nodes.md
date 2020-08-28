---
title: "Kubernetes Nodes 節點"
date: 2018-10-03T10:15:55-07:00
draft: false
weight: 40
---

所有組成 Kubernetes 集群的機器, 我們稱之為 **節點** (node)

Kubernetes 集群的節點(node) 可以是 具體的(physical) 或是 虛擬的 (virtual).  

節點有兩種(nodes): 

* 首先介紹的是控制面的節點(Control-plane-node), 透過這些節點來組成控制面 [控制面 Control Plane](../../architecture/architecture_control), 他扮演的角色是集群的**大腦**來下達指令.

* 接著就是工作者節點(Worker-node), 透過這些節點來組成 工作者面/資料面 [Data Plane](../../architecture/architecture_worker), 它就是真正用透過pod來運行容器映像檔(container image).

在後面的章節裡, 我們將會有更深入的介紹, 控制面與資料面如何互動
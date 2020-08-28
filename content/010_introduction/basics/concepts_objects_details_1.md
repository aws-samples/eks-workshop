---
title: "K8s 物件(Objects)的細節(Detail) (1/2)"
date: 2018-10-03T10:15:55-07:00
draft: false
weight: 60
---

### [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/)
* Pod 是可以在 Kubernetes 中創建和管理的、最小的可部署的計算單元。 Pod （就像在鯨魚莢或者豌豆莢中）是一組（一個或多個） 容器； 這些容器共享存儲、網絡、以及怎樣運行這些容器的聲明。 Pod 中的內容總是並置（colocated）的並且一同調度，在共享的上下文中運行。 Pod 所建模的是特定於應用的“邏輯主機”，其中包含一個或多個應用容器， 這些容器是相對緊密的耦合在一起的。在非雲環境中，在相同的物理機或虛擬機上運行的應用類似於 在同一邏輯主機上運行的雲應用。

### [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

* DaemonSet 是確保在 Kubernetes 中的每一個 node 上都會有一個指定的 pod 來運行特定的工作，當有新的 node 加入到 Kubernetes cluster 後，系統會自動在那個 node 上長出相同的 DaemonSet pod，當有 node 從 Kubernetes cluster 移除後，該 node 上的 DaemonSet pod 就會自動被清除掉。

### [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* Deployment 為 Pod 和 ReplicaSet 提供了一個聲明式定義（declarative）方法，用來替代以前的 ReplicationController 來方便的管理應用。

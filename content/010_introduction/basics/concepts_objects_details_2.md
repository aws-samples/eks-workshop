---
title: K8s 物件(Objects)的細節(Detail) (2/2)"
date: 2018-10-03T10:15:55-07:00
draft: false
weight: 70
---

### [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
* 主要的作用是維持一組Pod 的運行，它的主要作用就是保證一定數量的Pod 能夠在集群中正常運行，它會持續監聽這些Pod 的運行狀態，在Pod 發生故障重啟數量減少時重新運行新的Pod。

### [Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/)
* 主要的作用是維持一組Pod 副本的運行，它的主要作用就是保證一定數量的Pod 能夠在集群中正常運行，它會持續監聽這些Pod 的運行狀態，在Pod 發生故障重啟數量減少時重新運行新的Pod 副本。

### [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
* 對應一個固定的IP位址/網域名稱, 給一個 pods 的群

### [Label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
* 其實它的功能是一組組的鍵值 (Key/Value pairs)用來做關聯或是過濾 （association and filtering）

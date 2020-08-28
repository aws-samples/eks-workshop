---
title: "Control Plane 控制面"
date: 2018-10-03T10:18:27-07:00
draft: false
weight: 100
---

{{<mermaid>}}
graph TB
kubectl{kubectl}
  subgraph ControlPlane
    api(API Server)
    controller(Controller Manager)
    scheduler(Scheduler)
    etcd(etcd)
  end

  kubectl-->api
  controller-->api
  scheduler-->api
  api-->kubelet
  api-->etcd

  classDef green fill:#9f6,stroke:#333,stroke-width:4px;
  classDef orange fill:#f96,stroke:#333,stroke-width:4px;
  classDef blue fill:#6495ed,stroke:#333,stroke-width:4px;
  class api blue;
  class internet green;
  class kubectl orange;
{{< /mermaid >}}

The Control Plane 所代表的就是 Kubernetes 的控制面，其擁有的權力跟能力非常的巨大，從最基本資源的創建與監控(Pod/Deployment/Service)，資源的調度(Pod Schedule) 以及包括所有Kubernetes 上資源的存取(Secret/ConfigMap)。


* 1個或多個 API Servers: 其實就是 REST / kubectl 的接入點 (entry-point)

* etcd: 分散式的鍵值(key/value)儲存(store）

* Controller-manager: 其實就是叢集群內的控制器中心,負責集群內的Node、Pod副本、服務端點（Endpoint）、命名空間（Namespace）、服務賬號（ServiceAccount）、資源定額（ResourceQuota）的管理，當某個Node意外宕機時，Controller Manager會及時發現並執行自動化修復流程，確保集群始終處於預期的工作狀態。

* Scheduler: 安排 pods 到 worker nodes

想了解更多？  可以參考此連結 [官方 Kubernetes 文件(英文)](https://kubernetes.io/docs/concepts/overview/components/#master-components) for a more in-depth explanation of control plane components.

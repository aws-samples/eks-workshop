---
title: "Data Plane / Node 組件"
date: 2018-10-03T10:18:27-07:00
draft: false
weight: 110
---

{{<mermaid>}}
graph TB
internet((internet))
    subgraph worker1
      kubelet1(kubelet)
      kube-proxy1(kube-proxy)
      subgraph docker1
        subgraph podA
          containerA[container]
        end
        subgraph podB
          containerB[container]
        end
      end
    end

  internet-->kube-proxy1
  api-->kubelet1
  kubelet1-->containerA
  kubelet1-->containerB
  kube-proxy1-->containerA
  kube-proxy1-->containerB

  classDef green fill:#9f6,stroke:#333,stroke-width:4px;
  classDef orange fill:#f96,stroke:#333,stroke-width:4px;
  classDef blue fill:#6495ed,stroke:#333,stroke-width:4px;
  class api blue;
  class internet green;
  class kubectl orange;
{{< /mermaid >}}

* 由工作節點組成

* kubelet: 他的工作就是扮演介於 API Server 跟各個 node 之間的溝通渠道

* kube-proxy: 簡單來說, 它的功用是用來管理 IP 轉譯 (translation) 及 路由 (routing), 也可以被認知為負責為Pod創建代理服務，從apiserver獲取所有server信息，並根據server信息創建代理服務，實現server到Pod的請求路由和轉發，從而實現K8s層級的虛擬轉發網絡

想了解更多？  可以參考此連結 [the official Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/components/#node-components) for a more in-depth explanation of data plane components.

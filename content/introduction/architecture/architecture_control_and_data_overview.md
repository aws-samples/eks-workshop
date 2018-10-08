---
title: "Architectural Overview"
date: 2018-10-03T10:18:20-07:00
draft: false
weight: 90
---

{{<mermaid>}}
graph TB
internet((internet))
kubectl{kubectl}
  subgraph ControlPlane
    api(API Server)
    controller(Controller Manager)
    scheduler(Scheduler)
    etcd(etcd)
  end
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
    subgraph worker2
      kubelet2(kubelet)
      kube-proxy2(kube-proxy)
      subgraph docker2
        subgraph podC
          containerC[container]
        end
        subgraph podD
          containerD[container]
        end
      end
    end

  internet-->kube-proxy1
  internet-->kube-proxy2
  kubectl-->api
  controller-->api
  scheduler-->api
  api-->kubelet1
  api-->kubelet2
  api-->etcd
  kubelet1-->containerA
  kubelet1-->containerB
  kubelet2-->containerC
  kubelet2-->containerD
  kube-proxy1-->containerA
  kube-proxy1-->containerB
  kube-proxy2-->containerC
  kube-proxy2-->containerD

  classDef green fill:#9f6,stroke:#333,stroke-width:4px;
  classDef orange fill:#f96,stroke:#333,stroke-width:4px;
  classDef blue fill:#6495ed,stroke:#333,stroke-width:4px;
  class api blue;
  class internet green;
  class kubectl orange;
{{< /mermaid >}}

---
title: "Kubernetes 노드"
date: 2018-10-03T10:15:55-07:00
draft: false
weight: 40
---

Kubernetes클러스터를 구성하는 서버들을 **노드(Node)**라고 표현합니다.

Kubernetes의 node는 물리 혹은 가상 서버일 수 있습니다.

총 두가지 종류의 노드가 있습니다:

* 마스터 노드 (Master-node) - [Control Plane](../../architecture/architecture_control)을 구성하며, 클러스터의 "두뇌" 역할을 합니다.
* 워커 노드 (Worker-node) - [Data Plane](../../architecture/architecture_worker)을 구성하며, 실제 컨테이너 이미지를 실행합니다 (pod을 통해).

추후 해당 노드들이 어떻게 상호작용을 하는지 자세히 알아보도록 하겠습니다.

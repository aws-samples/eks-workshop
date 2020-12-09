---
title: "Deploying Rook and launch the Ceph Cluster components"
date: 2019-04-09T00:00:00-03:00
weight: 8
draft: false
---
#### Prerequisites

You must complete the [Start the Workshop](/020_prerequisites/workspace/) and [Launch using eksctl](/030_eksctl/) modules if you haven't already, then: 


We need to clone the Rook Github repository into our local file storage

```
git clone https://github.com/rook/rook.git
```

#### Deploy Rook as storage orchestrator

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/crds.yaml 
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/common.yaml
~/environment/rook/cluster/examples/kubernetes/ceph/config-admission-controller.sh
```

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/operator.yaml
```

Check if the rook Operator and infrastructure is started and ready to serve the Ceph Cluster

```
kubectl get all -n rook-ceph
```

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/cluster.yaml 
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/cluster-on-pvc.yaml 
```

Check if the the Cluster components are all up and running

```
kubectl get deployment -n rook-ceph
```

Create the StorageClass for our freshly deployed Ceph Block Storage Provider

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/storageclass.yaml
```
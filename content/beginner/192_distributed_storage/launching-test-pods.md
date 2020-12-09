---
title: "Launch test pvc and pod"
date: 2020-11-03T00:00:00-03:00
weight: 9
draft: false
---

# Deploy Test Pod

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/pvc.yaml
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/pod.yaml
``` 

Check if the PVC is bound and look how the deployment went: 

```
kubectl get pvc 
kubectl describe pvc
```

Check if the test pod has been launched successful:

```
timeout 20 watch -n 1 kubectl get po csirbd-demo-pod
```
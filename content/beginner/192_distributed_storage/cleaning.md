---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---
### Cleaning up

Once we are done, let's cleanup the resources specific to this module:

```
kubectl delete -f ~/environment/rook/cluster/examples/kubernetes/wordpress.yaml
kubectl delete -f ~/environment/rook/cluster/examples/kubernetes/mysql.yaml
kubectl delete -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/pod.yaml
kubectl delete -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/pvc.yaml 

kubectl delete -n rook-ceph cephblockpool replicapool
kubectl delete storageclass rook-ceph-block
kubectl delete -f ~/environment/rook/cluster/examples/kubernetes/ceph/crds.yaml 
```

We need to make sure that the deployed CRDs are deleted. So check with

```
kubectl -n rook-ceph get cephcluster
```

If no resources can be found continue with the deletion: 

```
kubectl delete -f ~/environment/rook/cluster/examples/kubernetes/ceph/operator.yaml
kubectl delete -f ~/environment/rook/cluster/examples/kubernetes/ceph/common.yaml 
```

If the last commands cannot finish, check with 

```
kubectl get ns rook-ceph 
```

If the namespace is still terminating. you can use the following command at a second terminal to enforce the deletion:

```
kubectl -n rook-ceph patch cephclusters.ceph.rook.io rook-ceph -p '{"metadata":{"finalizers": []}}' --type=merge
```

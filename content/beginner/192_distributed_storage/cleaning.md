---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---
### Cleaning up

#### Set the "stopped" node back into a working state

as we stopped Kubernetes to schedule any workload on the node holding the inital pods of our wordpress deployment we need to ensure to change it back into a working state. 

we can simply check the node affected using: 

```
kubectl get nodes
```

{{< output >}}
NAME                                           STATUS                     ROLES    AGE    VERSION
ip-192-168-43-123.us-west-2.compute.internal   Ready                      <none>   133m   v1.17.12-eks-7684af
ip-192-168-6-134.us-west-2.compute.internal    Ready,SchedulingDisabled   <none>   133m   v1.17.12-eks-7684af
ip-192-168-73-125.us-west-2.compute.internal   Ready                      <none>   133m   v1.17.12-eks-7684af
{{< /output >}}

Note down the Name of the node with "SchedulingDisabled" state, we'll need it in the next step. 

```
kubectl uncordon ip-192-168-6-134.us-west-2.compute.internal
```

{{< output >}}
node/ip-192-168-6-134.us-west-2.compute.internal uncordoned
{{< /output >}}

```
kubectl get nodes
```

{{< output >}}
NAME                                           STATUS                     ROLES    AGE    VERSION
ip-192-168-43-123.us-west-2.compute.internal   Ready                      <none>   134m   v1.17.12-eks-7684af
ip-192-168-6-134.us-west-2.compute.internal    Ready                      <none>   134m   v1.17.12-eks-7684af
ip-192-168-73-125.us-west-2.compute.internal   Ready                      <none>   134m   v1.17.12-eks-7684af
{{< /output >}}

#### Let's continue cleanup the resources specific to this module:

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

If the last command is taking forever, check with 

```
kubectl get ns rook-ceph 
```

If the namespace is still terminating. 
If it's the case you can use the following command at a second terminal to enforce the deletion:

```
kubectl -n rook-ceph patch cephclusters.ceph.rook.io rook-ceph -p '{"metadata":{"finalizers": []}}' --type=merge
```

Last we'll remove the created webhook configuration as it most likely has been missed by our prior deletion commands. 

```
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io rook-ceph-webhook
```

Done. 
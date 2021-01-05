---
title: "Launch test pvc and pod"
date: 2020-11-03T00:00:00-03:00
weight: 9
draft: false
---
#### Deploy Test Pod

We start with a first, simple test pod to ensure our freshly created distributed block storage works as expected. We'll create a PersistendVolumeClaim and a Pod consuming it and attaching a volume. 

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/pvc.yaml
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/pod.yaml
``` 

Then we're checking the PVC and ensure it is bond status.

```
kubectl get pvc 
```
{{< output >}}
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
rbd-pvc   Bound    pvc-3b97bd3d-78a5-43e8-b7ba-456e44dabeb9   1Gi        RWO            rook-ceph-block   48s
{{< /output >}}

Let's look into the pvc to get some more detailed information what's going on:

```
kubectl describe pvc
```

{{< output >}}
Name:          rbd-pvc
Namespace:     default
StorageClass:  rook-ceph-block
Status:        Bound
Volume:        pvc-3b97bd3d-78a5-43e8-b7ba-456e44dabeb9
Labels:        <none>
Annotations:   kubectl.kubernetes.io/last-applied-configuration:
                 {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"name":"rbd-pvc","namespace":"default"},"spec":{"accessMode...
               pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: rook-ceph.rbd.csi.ceph.com
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      1Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Mounted By:    csirbd-demo-pod
Events:
  Type    Reason                 Age                From                                                                                                        Message
  ----    ------                 ----               ----                                                                                                        -------
  Normal  ExternalProvisioning   14s (x4 over 42s)  persistentvolume-controller                                                                                 waiting for a volume to be created, either by external provisioner "rook-ceph.rbd.csi.ceph.com" or manually created by system administrator
  Normal  Provisioning           5s (x2 over 42s)   rook-ceph.rbd.csi.ceph.com_csi-rbdplugin-provisioner-76c6d64999-zxjz2_4d19a612-944d-433b-8bc4-ae8f9f9148af  External provisioner is provisioning volume for claim "default/rbd-pvc"
  Normal  ProvisioningSucceeded  5s (x2 over 5s)    rook-ceph.rbd.csi.ceph.com_csi-rbdplugin-provisioner-76c6d64999-zxjz2_4d19a612-944d-433b-8bc4-ae8f9f9148af  Successfully provisioned volume pvc-3b97bd3d-78a5-43e8-b7ba-456e44dabeb9
{{< /output >}}

We can see. Now a PersistentVolume has been provisioned and a PersistendVolumeClaim has been created and resulted into bond state. 

Taking a look on the created PersistentVolumes: 

```
kubectl get pv 
```

{{< output >}}
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS   REASON   AGE
pvc-08e672c1-74cb-4fa7-835e-3afcb14b5d6e   10Gi       RWO            Delete           Bound    rook-ceph/rook-ceph-mon-d     gp2                     15h
pvc-2788c147-8c3f-4985-9223-72eaaaaf5007   10Gi       RWO            Delete           Bound    rook-ceph/rook-ceph-mon-f     gp2                     15h
pvc-5c47ae18-47c7-47e4-a1e2-b96dc4ca723a   10Gi       RWO            Delete           Bound    rook-ceph/set1-data-1-cgpmf   gp2                     8h
pvc-69298a01-dcbc-40e0-86f2-77536ae0f862   10Gi       RWO            Delete           Bound    rook-ceph/set1-data-0-cl974   gp2                     8h
pvc-7091b179-5149-4f7d-ab60-c1fec81d78d3   10Gi       RWO            Delete           Bound    rook-ceph/rook-ceph-mon-g     gp2                     8h
pvc-ecb7fb73-1513-4d49-a3d6-3fdea201fe2f   10Gi       RWO            Delete           Bound    rook-ceph/set1-data-2-qt6qd   gp2                     8h
{{< /output >}}

On each host an Amazon EBS backed PersistentVolume has been provisioned by Ceph ensuring a distributed, highly available block storage endpoint is available for the pod we just deployed. 

Finally we check if the test pod has been launched successful:

```
kubectl get po csirbd-demo-pod
```

{{< output >}}
NAME              READY   STATUS    RESTARTS   AGE
csirbd-demo-pod   1/1     Running   0          6m7s
{{< /output >}}

Looking at the Events we can see the PersistenVolumeClaim we created to be utilized and a volume has been successfully attached to the pod. 

```
kubectl describe po csirbd-demo-pod
```

{{< output >}}
Events:
  Type     Reason                  Age                From                                                  Message
  ----     ------                  ----               ----                                                  -------
  Warning  FailedScheduling        14m (x5 over 14m)  default-scheduler                                     error while running "VolumeBinding" filter plugin for pod "csirbd-demo-pod": pod has unbound immediate PersistentVolumeClaims
  Normal   Scheduled               13m                default-scheduler                                     Successfully assigned default/csirbd-demo-pod to ip-192-168-6-134.us-west-2.compute.internal
  Normal   SuccessfulAttachVolume  13m                attachdetach-controller                               AttachVolume.Attach succeeded for volume "pvc-3b97bd3d-78a5-43e8-b7ba-456e44dabeb9"
  Normal   Pulling                 13m                kubelet, ip-192-168-6-134.us-west-2.compute.internal  Pulling image "nginx"
  Normal   Pulled                  13m                kubelet, ip-192-168-6-134.us-west-2.compute.internal  Successfully pulled image "nginx"
  Normal   Created                 13m                kubelet, ip-192-168-6-134.us-west-2.compute.internal  Created container web-server
  Normal   Started                 13m                kubelet, ip-192-168-6-134.us-west-2.compute.internal  Started container web-server
{{< /output >}}

After this short test lets build a more realistic test. 
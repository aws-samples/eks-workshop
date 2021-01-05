---
title: "Deploying Rook and launch the Ceph Cluster components"
date: 2019-04-09T00:00:00-03:00
weight: 8
draft: false
---
#### Prerequisites

You must complete the [Start the Workshop](/020_prerequisites/workspace/) and [Launch using eksctl](/030_eksctl/) modules if you haven't already, then: 


First of all we need to clone the Rook Github repository into our local file storage

```
cd ~
git clone https://github.com/rook/rook.git
```

#### Deploy Rook as storage orchestrator

Then we will deploy rook into our EKS Cluster to act as our storage orchestrator. We'll need some Custom Resources, Permissions, Secrets and the Admission Controller to be deployed. 

The Admission contoller intercepts requests to the Kubernetes API and provides an additional level of validation of rooks configuration using customer resource settings. 

The deployment and configuration can be triggered by simply using the pre-prepared templates and scripts out of the freshly cloned rook github repo:

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/crds.yaml 
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/common.yaml
~/environment/rook/cluster/examples/kubernetes/ceph/config-admission-controller.sh
```

Next as we do have the secrets and permissions in place we'll create the operator deployment itself. 

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/operator.yaml
```

Let's check if the rook operator and infrastructure is started and ready to serve the Ceph Cluster

```
kubectl get all -n rook-ceph
```

You should see an output similar to the following. 

{{< output >}}
NAME                                                  READY   STATUS    RESTARTS   AGE
pod/rook-ceph-admission-controller-7bc65fd8c5-49qhz   1/1     Running   0          4s
pod/rook-ceph-admission-controller-7bc65fd8c5-zqt9z   1/1     Running   0          4s
pod/rook-ceph-operator-9c757c4fd-r8rds                1/1     Running   0          6s

NAME                                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/rook-ceph-admission-controller   ClusterIP   10.100.182.52   <none>        443/TCP   4s

NAME                                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/rook-ceph-admission-controller   2/2     2            2           4s
deployment.apps/rook-ceph-operator               1/1     1            1           6s

NAME                                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/rook-ceph-admission-controller-7bc65fd8c5   2         2         2       4s
replicaset.apps/rook-ceph-operator-9c757c4fd                1         1         1       6s
{{< /output >}}

We successfully prepared our Amazon EKS Cluster and have our rook operator running.  

#### Deploy the Ceph Storage Cluster

Let's continue with the deployment of the the Ceph storage cluster.

For our deployment we'll choose the deployment of the cluster based on Persistent Volume Claims. This is a good choise for our AWS based environment as we would like our PVs to be created on-Demand on top of Amazon EBS. Ceph will then consume these PVs and provide them as distributed storage to our workload. 

To setup our Ceph cluster we'll deploy 2 templates: 

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/cluster.yaml 
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/cluster-on-pvc.yaml 
```

The deployment will take some minutes. So let's have a little sip on our coffee and check if the the Cluster components are all up and running using: 

```
kubectl get deployment -n rook-ceph
```

A successfull deployment will look like: 

{{< output >}}
NAME                                                        READY   UP-TO-DATE   AVAILABLE   AGE
csi-cephfsplugin-provisioner                                2/2     2            2           2m15s
csi-rbdplugin-provisioner                                   2/2     2            2           2m17s
rook-ceph-admission-controller                              2/2     2            2           11m
rook-ceph-crashcollector-cc5585710f3cce46f9ba86f1aa2867fc   0/1     1            0           52s
rook-ceph-mon-a                                             1/1     1            1           2m10s
rook-ceph-operator                                          1/1     1            1           11m
{{< /output >}}

The Ceph cluster is setup as a daemonset so the related pods will run on each node of our Amazon EKS cluster to ensure High Availability and Scalability of our Distributed Block Storage deployment. Let's check our deamonset with: 

```
kubectl get ds -n rook-ceph
```
{{< output >}}
NAME               DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-cephfsplugin   3         3         3       3            3           <none>          7m4s
csi-rbdplugin      3         3         3       3            3           <none>          7m5s
{{< /output >}}


Also we'll check how the needed csi plugin provisioners and management pods are distributed through our Amazon EKS cluster using: 

```
kubectl get po -n rook-ceph -o wide |grep csi-
```

{{< output >}}
csi-cephfsplugin-9bg8l                                            3/3     Running    0          9m14s   192.168.21.2     ip-192-168-21-2.us-west-2.compute.internal     <none>           <none>
csi-cephfsplugin-provisioner-744589d4d8-76mq6                     6/6     Running    0          9m13s   192.168.18.32    ip-192-168-21-2.us-west-2.compute.internal     <none>           <none>
csi-cephfsplugin-provisioner-744589d4d8-nms5l                     6/6     Running    0          9m13s   192.168.66.106   ip-192-168-82-90.us-west-2.compute.internal    <none>           <none>
csi-cephfsplugin-rhq7r                                            3/3     Running    0          9m14s   192.168.82.90    ip-192-168-82-90.us-west-2.compute.internal    <none>           <none>
csi-cephfsplugin-zpmkr                                            3/3     Running    0          9m14s   192.168.38.239   ip-192-168-38-239.us-west-2.compute.internal   <none>           <none>
csi-rbdplugin-gmhnt                                               3/3     Running    0          9m15s   192.168.38.239   ip-192-168-38-239.us-west-2.compute.internal   <none>           <none>
csi-rbdplugin-grfbh                                               3/3     Running    0          9m15s   192.168.21.2     ip-192-168-21-2.us-west-2.compute.internal     <none>           <none>
csi-rbdplugin-j98qk                                               3/3     Running    0          9m15s   192.168.82.90    ip-192-168-82-90.us-west-2.compute.internal    <none>           <none>
csi-rbdplugin-provisioner-747ffd4b5-t4zcn                         6/6     Running    0          9m15s   192.168.38.45    ip-192-168-38-239.us-west-2.compute.internal   <none>           <none>
csi-rbdplugin-provisioner-747ffd4b5-zrg49                         6/6     Running    0          9m15s   192.168.27.57    ip-192-168-21-2.us-west-2.compute.internal     <none>           <none>
{{< /output >}}

If everything is in a running state we have a working Ceph cluster on our Amazon EKS cluster. As the final step before seting up some test deployments let's create a storage class utilizing our setup which we can use for our workloads: 

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/ceph/csi/rbd/storageclass.yaml
```

Check with: 

```
kubectl get storageclasses.storage.k8s.io 
```

{{< output >}}
NAME              PROVISIONER                  RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)     kubernetes.io/aws-ebs        Delete          WaitForFirstConsumer   false                  27d
rook-ceph-block   rook-ceph.rbd.csi.ceph.com   Delete          Immediate              true                   10s
{{< /output >}}

Now we do have two storageclasses setup. The storageclass gp2 is the default created when we initially deployed our Amazon EKS cluster using eksctl. 'rook-ceph-block' is our freshly created, Ceph based distributed block storage strorageclass we will use in our examples and test deployments. 
The gp2 storageclass is utilized by our Ceph cluster as backend to setup the PersistentVolumes for our distributed storage setup. 
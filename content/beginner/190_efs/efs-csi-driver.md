---
title: "EFS Provisioner for EKS with CSI Driver"
date: 2020-09-01T00:00:00-03:00
weight: 12
draft: false
---

## About the Amazon EFS CSI Driver
On Amazon EKS, the open-source [EFS Container Storage Interface (CSI)](https://github.com/kubernetes-sigs/aws-efs-csi-driver) driver is used to manage the attachment of Amazon EFS volumes to Kubernetes Pods.

## Deploy EFS CSI Driver

We are going to deploy the driver using the stable release:

```
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.0"
```

Verify pods have been deployed:
```
kubectl get pods -n kube-system
```

Should return new pods with csi driver:

Output: 
{{< output >}}
NAME                       READY   STATUS    RESTARTS   AGE
efs-csi-node-8hgpt         3/3     Running   0          6h11m
efs-csi-node-d7r47         3/3     Running   0          6h11m
efs-csi-node-fs49j         3/3     Running   0          6h11m
{{< /output >}}


## Create Persistent Volume
Next we will deploy a persistent volume using the EFS created. 
```
mkdir ~/environment/efs
cd ~/environment/efs
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-pvc.yaml
```

We need to update this manifest with the EFS ID created:
```
sed -i "s/EFS_VOLUME_ID/$FILE_SYSTEM_ID/g" efs-pvc.yaml
```

And then apply:
```
kubectl apply -f efs-pvc.yaml
```

Next, check if a PVC resource was created. The output from the command should look similar to what is shown below, with the **STATUS** field set to **Bound**.
```
kubectl get pvc -n storage
```

Output: 
{{< output >}}
NAME                STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
efs-storage-claim   Bound    efs-pvc   5Gi        RWX            efs-sc         4s
{{< /output >}}


A PV corresponding to the above PVC is dynamically created. Check its status with the following command.
```
kubectl get pv
```

Output: 
{{< output >}}
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS   REASON   AGE
efs-pvc   5Gi        RWX            Retain           Bound    storage/efs-storage-claim   efs-sc                  20s
{{< /output >}}

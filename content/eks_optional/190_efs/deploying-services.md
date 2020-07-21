---
title: "Deploying the Stateful Services"
date: 2019-04-09T00:00:00-03:00
weight: 14
draft: false
---

Next, launch a set of two pods with the following commands.
```
cd ~/environment/efs
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-writer.yaml
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-reader.yaml
kubectl apply -f efs-writer.yaml
kubectl apply -f efs-reader.yaml
```

Each one of these pods references the PVC resource named **efs-storage-claim** created earlier and mounts the backing PV to a local directory named **/shared**.


Verify that the **efs-writer** pod is successfully writing data to the shared persistent volume.
```
kubectl exec -it efs-writer -n storage -- tail /shared/out.txt
```
The output from the above command will look as follows:
{{< output >}}
efs-writer.storage - Thu Mar 5 20:52:19 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:24 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:29 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:34 UTC 2020
{{< /output >}}


Verify that the **efs-reader** pod is able to successfully read the same data from the shared persistent volume.
```
kubectl exec -it efs-reader -n storage -- tail /shared/out.txt
```
The output from the above command will be the same as the one from the  **efs-writer** pod.
{{< output >}}
efs-writer.storage - Thu Mar 5 20:52:19 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:24 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:29 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:34 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:39 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:44 UTC 2020
{{< /output >}}

Verify that this file resides on the EFS file system using EFS Provisioner pod. Note that the names of the EFS Provisioner pod and the directory will be different in your environment.
```
kubectl exec -it efs-provisioner-849b6f77cb-rn9jb -n storage -- tail -f /efs-mount/efs-storage-claim-pvc-8e470e71-5a24-11ea-9a37-0a95e5bfd098/out.txt
```
Output:
{{< output >}}
efs-writer.storage - Thu Mar 5 20:52:19 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:24 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:29 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:34 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:39 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:44 UTC 2020
efs-writer.storage - Thu Mar 5 20:52:49 UTC 2020
{{< /output >}}

Delete both the efs-writer and efs-reader pods 
```
kubectl delete pod efs-writer -n storage
kubectl delete pod efs-reader -n storage
```
Verify that the file **out.txt** continues to live on the EFS file system.
```
kubectl exec -it efs-provisioner-849b6f77cb-rn9jb -n storage -- tail -f /efs-mount/efs-storage-claim-pvc-8e470e71-5a24-11ea-9a37-0a95e5bfd098/out.txt
```


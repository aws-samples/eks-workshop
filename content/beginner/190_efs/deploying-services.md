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

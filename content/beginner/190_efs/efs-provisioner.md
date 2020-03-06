---
title: "EFS Provisioner for EKS: How it Works"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---

The [EFS Provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs) is deployed as a Pod that has a container with access to an AWS EFS file system. The container reads a **ConfigMap** containing the File system ID, Amazon Region of the EFS file system, and the name of the provisioner as shown below.
![ConfigMap](/images/efs-provisioner/configmap.png)

A **StorageClass** resource is defined whose <span style="color: blue;">*provisioner*</span> attribute determines which volume plugin is used for provisioning a **PersistentVolume** (PV). In this case, the StorageClass specifies the EFS Provisioner Pod as an external provisioner by referencing the value of <span style="color: blue;">*provisioner.name*</span> key in the ConfigMap above.
![ConfigMap](/images/efs-provisioner/storageclass.png)

A **PersistentVolumeClaim** (PVC) resource is created that references the above StorageClass using the annotation <span style="color: blue;">*volume.beta.kubernetes.io/storage-class*</span>. A PVC represents a request for storage by a user.
![ConfigMap](/images/efs-provisioner/pvc.png)

A sub-directory named <b>data</b> was created under the root of the EFS file system for the EFS Provisioner Pod to use. This is configured in the EFS Provisioner deployment manifest under <span style="color: blue;">*volumes/nfs/path*</span>. This directory is then mounted on to a local directory within the pod specified in the manifest under <span style="color: blue;">*containers/volumeMounts/mountPath*</span>. The EFS Provisioner Pod will create child directories under this directory to back each PV it provisions.  
![ConfigMap](/images/efs-provisioner/provisioner.png)

With the above setup, EKS resources such as **Deployments, CronJobs, StatefulSets** etc. that need a persistent volume for data storage on the EFS file system may request one by referencing an instance of PVC in their respective YAML manifest such that its <span style="color: blue;">*claimName*</span> attribute under <span style="color: blue;">*volumes/persistentVolumeClaim*</span> matches the <span style="color: blue;">*name*</span> attribute of a PVC definition. If a PV that matches the PVC request does not yet exist, it will be dynamically provisioned and then mounted on to a local directory within the pod specified in the manifest under <span style="color: blue;">*containers/volumeMounts/mountPath*</span>.
![ConfigMap](/images/efs-provisioner/deployment.png)

{{% notice info %}}
If different sets of microservices in your deployment need to share different directories, then you need to create a new instance of a PersistentVolumeClaim for each shared directory. The corresponding PersistentVolume will be backed by a new child directory created under the top-level directory **/data** on the same EFS file system. There is no need to provision a new instance of an EFS file system unless your data isolation requirements demand as such.
{{% /notice %}}
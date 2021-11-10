---
title: "Define Storageclass"

date: 2018-08-07T08:30:11-07:00
weight: 5
---
## Introduction

[Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) allows storage volumes to be created on-demand. [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) should be pre-created to define which provisioner should be used and what parameters should be passed when dynamic provisioning is invoked.

## Define Storage Class

Copy/Paste the following commands into your Cloud9 Terminal.

```sh
cat << EoF > ${HOME}/environment/ebs_statefulset/mysql-storageclass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: mysql-gp2
provisioner: ebs.csi.aws.com # Amazon EBS CSI driver
parameters:
  type: gp2
  encrypted: 'true' # EBS volumes will always be encrypted by default
volumeBindingMode: WaitForFirstConsumer # EBS volumes are AZ specific
reclaimPolicy: Delete
mountOptions:
- debug
EoF
```

You can see that:

* The provisioner is `ebs.csi.aws.com`.
* The volume type is [General Purpose SSD volumes (gp2)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html#EBSVolumeTypes_gp2).
* The `encrypted` parameter will ensure the EBS volumes are encrypted by default.
* The [volumeBindingMode](https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode) is `WaitForFirstConsumer` to ensure persistent volume will be provisioned after Pod is created so they reside in the same AZ

Create storageclass `mysql-gp2` by following command.

```sh
kubectl create -f ${HOME}/environment/ebs_statefulset/mysql-storageclass.yaml
```

You can verify the StorageClass and its options with this command.

```sh
kubectl describe storageclass mysql-gp2
```

{{< output >}}
Name:                  mysql-gp2
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           ebs.csi.aws.com
Parameters:            encrypted=true,type=gp2
AllowVolumeExpansion:  <unset>
MountOptions:
  debug
ReclaimPolicy:      Delete
VolumeBindingMode:  WaitForFirstConsumer
Events:             <none>
{{< /output >}}

Below is a preview of how the storageClassName will be used in defining the StatefulSet. We will specify `mysql-gp2` as the storageClassName in volumeClaimTemplates at “Create StatefulSet” section later.

{{< output >}}
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: mysql-gp2
      resources:
        requests:
          storage: 10Gi
{{< /output >}}

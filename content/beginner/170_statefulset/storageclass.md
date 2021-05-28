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
  name: mysql-gp3
provisioner: ebs.csi.aws.com # Amazon EBS CSI driver
parameters:
  type: gp3
  encrypted: 'true' # EBS volumes will always be encrypted by default
reclaimPolicy: Delete
mountOptions:
- debug
EoF
```

You can see that:

* The provisioner is `ebs.csi.aws.com`.
* The volume type is [General Purpose SSD volumes (gp3)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html#EBSVolumeTypes_gp3).
* The `encrypted` parameter will ensure the EBS volumes are encrypted by default.

Create storageclass `mysql-gp3` by following command.

```sh
kubectl create -f ${HOME}/environment/ebs_statefulset/mysql-storageclass.yaml
```

You can verify the StorageClass and its options with this command.

```sh
kubectl describe storageclass mysql-gp3
```

{{< output >}}
Name:                  mysql-gp3
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           ebs.csi.aws.com
Parameters:            encrypted=true,type=gp3
AllowVolumeExpansion:  <unset>
MountOptions:
  debug
ReclaimPolicy:      Delete
VolumeBindingMode:  Immediate
Events:             <none>
{{< /output >}}

We will specify `mysql-gp3` as the storageClassName in volumeClaimTemplates at “Create StatefulSet” section later.

{{< output >}}
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: mysql-gp3
      resources:
        requests:
          storage: 10Gi
{{< /output >}}

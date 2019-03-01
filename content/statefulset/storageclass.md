---
title: "Define Storageclass"

date: 2018-08-07T08:30:11-07:00
weight: 5
---
#### Introduction
[Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) allows storage volumes to be created on-demand. [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) should be pre-created to define which provisoner should be used and what parameters should be passed when dynamic provisioning is invoked.
(See parameters for [AWS EBS](https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs))
#### Define Storage Class
Copy/Paste the following commands into your Cloud9 Terminal. 
```
mkdir ~/environment/templates
cd ~/environment/templates
wget https://eksworkshop.com/statefulset/storageclass.files/mysql-storageclass.yml
```
Check the configuration of mysql-storageclass.yml file by following command.
```
cat ~/environment/templates/mysql-storageclass.yml
```
You can see provisioner is kubernetes.io/aws-ebs and type is gp2 specified as a parameter. 
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: mysql-gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Delete
mountOptions:
- debug
```

Create storageclass "mysql-gp2" by following command. 
```
kubectl create -f ~/environment/templates/mysql-storageclass.yml
```

We will specify "mysql-gp2" as the storageClassName in volumeClaimTemplates at "Create StatefulSet" section later.
```
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: mysql-gp2
      resources:
        requests:
          storage: 10Gi
```

{{%attachments title="Related files" pattern=".yml"/%}}

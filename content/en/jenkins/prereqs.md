---
title: "Configure Storage Class"
date: 2018-08-07T08:30:11-07:00
weight: 10
draft: true
---

Before we can deploy our `Jenkins` instance we need to go and configure a
default storage class for our cluster. Storage Classes tell Kubernetes how they
should configure the Persistent Volumes that will be used with the cluster.

In our example we're going to setup `gp2` or general purpose EBS as our backing
`pvc`'s

First we need to create a new storage manifest:
```
cat <<EoF > ~/environment/storage-class.yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2
  annotations:
    "storageclass.kubernetes.io/is-default-class": "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
mountOptions:
  - debug
EoF
```

Lastly apply the config.

```
kubectl apply -f ~/environment/storage-class.yaml
```

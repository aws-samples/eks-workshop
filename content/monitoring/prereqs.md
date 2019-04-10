---
title: "Prereqs"
weight: 5
draft: false
---

#### Is **helm** installed?

We will use **helm** to install Prometheus & Grafana monitoring tools for this chapter. Please review  [installing helm chapter](/helm_root/helm_intro/install/index.html) for instructions if you don't have it installed.

```
helm ls
```
#### Configure Storage Class

We will use **gp2** EBS volumes for simplicity and demonstration purpose. While deploying in Production, you would use **io1** volumes with desired IOPS and increase the default storage size in the manifests to get better performance.

Save the below manifest as **_prometheus-storageclass.yaml_** using your favorite editor.

#### Challenge:
**You need to update provisioner value that is applicable to AWS EBS provisioner. Please see [Kubernetes documentation] (https://kubernetes.io/docs/concepts/storage/storage-classes/) for help**

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: prometheus
  namespace: prometheus
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
mountOptions:
  - debug
```

**Create storageclass "prometheus" by applying proper kubectl command**

```
kubectl create -f prometheus-storageclass.yaml
```
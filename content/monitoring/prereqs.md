---
title: "Prereqs"
date: 2018-10-14T19:56:14-04:00
weight: 5
draft: false
---

#### Is `helm` installed?

We will use **helm** to install Prometheus & Grafana monitoring tools for this chapter. Please review  [installing helm chapter](../../helm/install) for instructions if you don't have it installed

```
helm ls
```

#### Configure Storage Class

We will use **gp2** EBS volumes for simplicity and demonstration purpose. While deploying in Production, you would use **io1** volumes with desired IOPS and increase the default storage size in the manifests to get better performance.

```
kubectl create -f - <<EOF
{
  "kind": "StorageClass",
  "apiVersion": "storage.k8s.io/v1",
  "metadata": {
    "name": "prometheus",
    "namespace": "prometheus"
  },
  "provisioner": "kubernetes.io/aws-ebs",
  "parameters": {
    "type": "gp2"
  },
  "reclaimPolicy": "Retain",
  "mountOptions": [
    "debug"
  ]  
}
EOF
```

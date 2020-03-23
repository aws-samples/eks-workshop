---
title: "Install Velero"
weight: 20
draft: false
---

#### Install Velero binary

Download the [latest release's](https://github.com/vmware-tanzu/velero/releases/latest) tarball for your client platform (Example: velero-v1.3.1-linux-amd64.tar.gz)
Extract the tarball:
  ``` 
  tar -xvf <RELEASE-TARBALL-NAME>.tar.gz -C /tmp
  ```
Move the extracted velero binary to /usr/local/bin
```
mv /tmp/velero-v1.3.1-linux-amd64/velero /usr/local/bin
```
Verify installation
```
velero version
```

#### Install Velero on EKS

Let's install velero on EKS. All the velero resources will be created in a namespace called velero.

```
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.0.1 \
    --bucket $BUCKET \
    --backup-location-config region=$AWS_REGION \
    --snapshot-location-config region=$AWS_REGION \
    --secret-file ./credentials-velero
```

Inspect the resources created.

```
kubectl get all -n velero
```
Output should look something like this:

```
NAME                          READY   STATUS    RESTARTS   AGE
pod/velero-845db94ffd-7c57h   1/1     Running   0          5h56m

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/velero   1/1     1            1           5h56m

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/velero-845db94ffd   1         1         1       5h56m
```
---
title: "Create ConfigMap"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

#### Introduction
[ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) allow you to decouple configuration artifacts and secrets from image content to keep containerized applications portable. Using ConfigMap, you can independently control MySQL configuration. In this lab, we will use master to serve replication logs to slave and slaves are read-only. 

#### Create ConfigMap
Copy/Paste the following commands into your Cloud9 Terminal.
```
cd ~/environment/templates
wget https://eksworkshop.com/statefulset/configmap.files/mysql-configmap.yml

```
Check the configuration of mysql-configmap.yml file by following command.
```
cat ~/environment/templates/mysql-configmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  labels:
    app: mysql
data:
  master.cnf: |
    # Apply this config only on the master.
    [mysqld]
    log-bin
  slave.cnf: |
    # Apply this config only on slaves.
    [mysqld]
    super-read-only
```
Check configmap "mysql-config" created by following command.
```
kubectl create -f ~/environment/templates/mysql-configmap.yml
configmap "mysql-config" created
```

{{%attachments title="Related files" pattern=".yml"/%}}

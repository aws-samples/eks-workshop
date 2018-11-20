---
title: "Create ConfigMap"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

#### Introduction
[ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) allow you to decouple configuration artifacts and secrets from image content to keep containerized applications portable. Using ConfigMap, you can independently control MySQL configuration. 

#### Create ConfigMap
Copy/Paste the following commands into your Cloud9 Terminal.
```
cd ~/environment/templates
wget https://eksworkshop.com/statefulset/configmap.files/mysql-configmap.yml

```
Check the configuration of mysql-configmap.yml file by following command.
```
cat ~/environment/templates/mysql-configmap.yml
```
ConfigMap stores master.cnf, slave.cnf and pass them when initializing master and slave pods defined in statefulset. **master.cnf** is for the MySQL master pod which has binary log option (log-bin) to provides a record of the data changes to be sent to slave servers and **slave.cnf** is for slave pods which has super-read-only option.
```
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

Create configmap "mysql-config" by following command.
```
kubectl create -f ~/environment/templates/mysql-configmap.yml
```

{{%attachments title="Related files" pattern=".yml"/%}}

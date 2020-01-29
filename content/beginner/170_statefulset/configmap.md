---
title: "Create ConfigMap"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

#### Introduction
[ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) allow you to decouple configuration artifacts and secrets from image content to keep containerized applications portable. Using ConfigMap, you can independently control MySQL configuration. 

#### Create the mysql Namespace
We will create a new `Namespace` called `mysql` that will host all the components.
```sh
kubectl create namespace mysql
```

#### Create ConfigMap
Run the following commands to download the `ConfigMap`.
```sh
cd ~/environment/templates
wget https://eksworkshop.com/beginner/170_statefulset/configmap.files/mysql-configmap.yml

```

Check the configuration of mysql-configmap.yml file.
```sh
cat ~/environment/templates/mysql-configmap.yml
```

The `ConfigMap` stores master.cnf, slave.cnf and passes them when initializing master and slave pods defined in StatefulSet:
* **master.cnf** is for the MySQL master pod which has binary log option (log-bin) to provides a record of the data changes to be sent to slave servers.
* **slave.cnf** is for slave pods which have super-read-only option.
{{< output >}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: mysql
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
{{< /output >}}

Create "mysql-config" `ConfigMap`.
```sh
kubectl create -f ~/environment/templates/mysql-configmap.yml
```

{{%attachments title="Related files" pattern=".yml"/%}}

---
title: "Create ConfigMap"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

## Introduction

[ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) allow you to decouple configuration artifacts and secrets from image content to keep containerized applications portable. Using ConfigMap, you can independently control the MySQL configuration.

## Create the mysql Namespace

We will create a new `Namespace` called `mysql` that will host all the components.

```sh
kubectl create namespace mysql
```

## Create ConfigMap

Run the following commands to create the `ConfigMap`.

```sh
cd ${HOME}/environment/ebs_statefulset

cat << EoF > ${HOME}/environment/ebs_statefulset/mysql-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: mysql
  labels:
    app: mysql
data:
  master.cnf: |
    # Apply this config only on the leader.
    [mysqld]
    log-bin
  slave.cnf: |
    # Apply this config only on followers.
    [mysqld]
    super-read-only
EoF
```

The `ConfigMap` stores `master.cnf`, `slave.cnf` and passes them when initializing leader and follower pods defined in StatefulSet:

* **master.cnf** is for the MySQL leader pod which has binary log option (log-bin) to provides a record of the data changes to be sent to follower servers.
* **slave.cnf** is for follower pods which have super-read-only option.

Create "mysql-config" `ConfigMap`.

```sh
kubectl create -f ${HOME}/environment/ebs_statefulset/mysql-configmap.yaml
```

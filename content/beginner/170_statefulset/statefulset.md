---
title: "Create StatefulSet"
date: 2018-08-07T08:30:11-07:00
weight: 20
---
## Introduction

StatefulSet consists of serviceName, replicas, template and volumeClaimTemplates:

* **serviceName** is "mysql", headless service we created in previous section
* **replicas** is 3, the desired number of pod
* **template** is the configuration of pod
* **volumeClaimTemplates** is to claim volume for pod based on storageClassName, `mysql-gp2` that we created in the [Define Storageclass](/beginner/170_statefulset/storageclass/) section.

{{% notice info %}}
[Percona Xtrabackup](https://www.percona.com/software/mysql-database/percona-xtrabackup) is used in the template to clone source MySQL server to its followers.
{{% /notice %}}

## Create StatefulSet

Copy/Paste the following commands into your Cloud9 Terminal.

```sh
cd ${HOME}/environment/ebs_statefulset
wget https://eksworkshop.com/beginner/170_statefulset/statefulset.files/mysql-statefulset.yaml
```

Create the `StatefulSet` "mysql" by running the following command.

```sh
kubectl apply -f ${HOME}/environment/ebs_statefulset/mysql-statefulset.yaml
```

## Watch StatefulSet

Watch the status of `StatefulSet`.

```sh
kubectl -n mysql rollout status statefulset mysql
```

It will take few minutes for pods to initialize and have `StatefulSet` created.

{{< output >}}
Waiting for 2 pods to be ready...
Waiting for 1 pods to be ready...
partitioned roll out complete: 2 new pods have been updated...
{{< /output >}}

Open another Cloud9 Terminal and watch the progress of pods creation using the following command.

```sh
kubectl -n mysql get pods -l app=mysql --watch
```

You can see ordered, graceful deployment with a stable, unique name for each pod.

{{< output >}}
NAME      READY   STATUS           RESTARTS    AGE
mysql-0   0/2     Init:0/2          0          16s
mysql-0   0/2     Init:1/2          0          17s
mysql-0   0/2     PodInitializing   0          18s
mysql-0   1/2     Running           0          19s
mysql-0   2/2     Running           0          25s
mysql-1   0/2     Pending           0          0s
mysql-1   0/2     Pending           0          0s
mysql-1   0/2     Init:0/2          0          0s
mysql-1   0/2     Init:1/2          0          10s
mysql-1   0/2     PodInitializing   0          11s
mysql-1   1/2     Running           0          12s
mysql-1   2/2     Running           0          16s
{{< /output >}}

{{% notice info %}}
Press Ctrl+C to stop watching.
{{% /notice %}}

Check the dynamically created PVC by following command.

```sh
kubectl -n mysql get pvc -l app=mysql
```

We can see `data-mysql-0`, and `data-mysql-1` have been created with the STORAGECLASS `mysql-gp2`.

{{< output >}}
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-mysql-0   Bound    pvc-2a9bb222-3fbe-11ea-94be-0aff3e98c5a0   10Gi       RWO            mysql-gp2      22m
data-mysql-1   Bound    pvc-47076f1d-3fbe-11ea-94be-0aff3e98c5a0   10Gi       RWO            mysql-gp2      21m
{{< /output >}}

And now the same information from the EC2 console.

{{% notice tip %}}
We can see the EBS volumes have been automatically encrypted by the [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/)
{{% /notice %}}

![EBS_volume](/images/statefulset/ebs_volume.png)

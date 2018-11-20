---
title: "Create StatefulSet"
date: 2018-08-07T08:30:11-07:00
weight: 20
---
#### Introduction
StatefulSet consists of serviceName, replicas, template and volumeClaimTemplates.
**serviceName** is "mysql", headless service we created in previous section, **replicas** is 3, the desired number of pod, **template** is the configuration of pod, **volumeClaimTemplates** is to claim volume for pod based on storageClassName, gp2 that we created in "Define Storageclass" section. [Percona Xtrabackup](https://www.percona.com/software/mysql-database/percona-xtrabackup) is in template to clone source MySQL server to its slaves.
#### Create StatefulSet
Copy/Paste the following commands into your Cloud9 Terminal.
```
cd ~/environment/templates
wget https://eksworkshop.com/statefulset/statefulset.files/mysql-statefulset.yml
```
Create statefulset "mysql" by following command.
```
kubectl create -f ~/environment/templates/mysql-statefulset.yml
```
#### Watch StatefulSet
Watch the status of statefulset.
```
kubectl get -w statefulset
```
It will take few minutes for pods to initialize and have statefulset created.
**DESIRED** is the replicas number you define at StatefulSet.
```
NAME      DESIRED   CURRENT   AGE
mysql     3         1         8s
mysql     3         2         59s
mysql     3         3         2m
mysql     3         3         3m
```
Open another Cloud9 Terminal and watch the progress of pods creation using the following command. 
```
kubectl get pods -l app=mysql --watch
```
You can see ordered, graceful deployment with a stable, unique name for each pod.
```
NAME      READY     STATUS     RESTARTS   AGE
mysql-0   0/2       Init:0/2   0          30s
mysql-0   0/2       Init:1/2   0         35s
mysql-0   0/2       PodInitializing   0         47s
mysql-0   1/2       Running   0         48s
mysql-0   2/2       Running   0         59s
mysql-1   0/2       Pending   0         0s
mysql-1   0/2       Pending   0         0s
mysql-1   0/2       Pending   0         0s
mysql-1   0/2       Init:0/2   0         0s
mysql-1   0/2       Init:1/2   0         35s
mysql-1   0/2       Init:1/2   0         45s
mysql-1   0/2       PodInitializing   0         54s
mysql-1   1/2       Running   0         55s
mysql-1   2/2       Running   0         1m
mysql-2   0/2       Pending   0         <invalid>
mysql-2   0/2       Pending   0         <invalid>
mysql-2   0/2       Pending   0         0s
mysql-2   0/2       Init:0/2   0         0s
mysql-2   0/2       Init:1/2   0         32s
mysql-2   0/2       Init:1/2   0         43s
mysql-2   0/2       PodInitializing   0         50s
mysql-2   1/2       Running   0         52s
mysql-2   2/2       Running   0         56s
```
Press Ctrl+C to stop watching.

Check the dynamically created PVC by following command.
```
kubectl get pvc -l app=mysql
```
You can see data-mysql-0,1,2 are created by STORAGECLASS mysql-gp2.
```
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-mysql-0   Bound     pvc-83e9dfeb-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-1   Bound     pvc-977e7806-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-2   Bound     pvc-b3009b02-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
```
(Optional) Check 10Gi 3 EBS volumes are created across availability zones at your AWS console.
{{%attachments title="Related files" pattern=".yml"/%}}

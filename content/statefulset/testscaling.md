---
title: "Test Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 35
---
More slaves can be added to the MySQL Cluster to increase read capacity. This can be done by following command.
```
kubectl scale statefulset mysql --replicas=5
```
You can see the message that statefulset "mysql" scaled.
```
statefulset "mysql" scaled
```
Watch the progress of ordered and graceful scaling.
```
kubectl get pods -l app=mysql -w
```
```
NAME      READY     STATUS     RESTARTS   AGE
mysql-0   2/2       Running    0          1d
mysql-1   2/2       Running    0          1d
mysql-2   2/2       Running    0          24m
mysql-3   0/2       Init:0/2   0          8s
mysql-3   0/2       Init:1/2   0         9s
mysql-3   0/2       PodInitializing   0         11s
mysql-3   1/2       Running   0         12s
mysql-3   2/2       Running   0         16s
mysql-4   0/2       Pending   0         0s
mysql-4   0/2       Pending   0         0s
mysql-4   0/2       Init:0/2   0         0s
mysql-4   0/2       Init:1/2   0         10s
mysql-4   0/2       PodInitializing   0         11s
mysql-4   1/2       Running   0         12s
mysql-4   2/2       Running   0         17s

```

{{% notice note %}}
It may take few minutes to launch all the pods.
{{% /notice %}}

Press Ctrl+C to stop watching.
Open another terminal to check loop if you closed it.
```
kubectl run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\
   bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id,NOW()'; done"
```
You will see 5 servers are running.
```
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         101 | 2018-11-14 13:56:42 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         102 | 2018-11-14 13:56:43 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         104 | 2018-11-14 13:56:44 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2018-11-14 13:56:45 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         104 | 2018-11-14 13:56:46 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         101 | 2018-11-14 13:56:47 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2018-11-14 13:56:48 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         103 | 2018-11-14 13:56:49 |
+-------------+---------------------+
```
Verify if the newly deployed slave (mysql-3) have the same data set by following command.
```
kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
 mysql -h mysql-3.mysql -e "SELECT * FROM test.messages"
```
It will show the same data that master has.
```
+--------------------------+
| message                  |
+--------------------------+
| hello, from mysql-client |
+--------------------------+
```
Scale down replicas to 3 by following command.
```
kubectl scale statefulset mysql --replicas=3
```
You can see statefulset "mysql" scaled
```
statefulset "mysql" scaled
```
Note that scale in doesn't delete the data or PVCs attached to the pods. You have to delete them manually.
Check scale in is completed by following command.
```
kubectl get pods -l app=mysql
```
```
NAME      READY     STATUS    RESTARTS   AGE
mysql-0   2/2       Running   0          1d
mysql-1   2/2       Running   0          1d
mysql-2   2/2       Running   0          35m
```

Check 2 PVCs(data-mysql-3, data-mysql-4) still exist by following command.
```
kubectl get pvc -l app=mysql
```
```
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-mysql-0   Bound     pvc-83e9dfeb-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-1   Bound     pvc-977e7806-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-2   Bound     pvc-b3009b02-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-3   Bound     pvc-de14acd8-e811-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            34m
data-mysql-4   Bound     pvc-e916c3ec-e812-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            26m
```


#### Challenge:
**By default, deleting a PersistentVolumeClaim will delete its associated persistent volume. What if you wanted to keep the volume? Change the reclaim policy of the PersistentVolume associated with PVC "data-mysql-3" to "Retain". Please see [Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/) for help**

{{% expand "Expand here to see the solution"%}}
Change the reclaim policy:
```
kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```
Now, if you delete the PersistentVolumeClaim data-mysql-3, you can still see the EBS volume in your AWS EC2 console, with its state as "available".

Let's change the reclaim policy back to "Delete" to avoid orphaned volumes:
```
kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
```
{{%/expand%}}

Delete data-mysql-3, data-mysql-4 by following command.
```
kubectl delete pvc data-mysql-3
kubectl delete pvc data-mysql-4
```
```
persistentvolumeclaim "data-mysql-3" deleted
persistentvolumeclaim "data-mysql-4" deleted
```

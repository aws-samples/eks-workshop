---
title: "Test Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 35
---
More slaves can be added to the MySQL Cluster to increase read capacity. This can be done by following command.
```sh
kubectl -n mysql scale statefulset mysql --replicas=5
```

You can see the message that `StatefulSet` "mysql" scaled.
{{< output >}}
statefulset "mysql" scaled
{{< /output >}}

Watch the progress of ordered and graceful scaling.
```sh
kubectl -n mysql rollout status statefulset mysql
```
{{< output >}}
Waiting for 2 pods to be ready...
Waiting for 1 pods to be ready...
partitioned roll out complete: 5 new pods have been updated...
{{< /output >}}

{{% notice note %}}
It may take few minutes to launch all the pods.
{{% /notice %}}

Open another terminal to check loop if you closed it.
```sh
kubectl -n mysql run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\
   bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id,NOW()'; done"
```

You will see 5 servers are running.
{{< output >}}
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2020-01-25 02:32:43 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         102 | 2020-01-25 02:32:44 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         101 | 2020-01-25 02:32:45 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         103 | 2020-01-25 02:32:46 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         104 | 2020-01-25 02:32:47 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         103 | 2020-01-25 02:32:48 |
+-------------+---------------------+
{{< /output >}}

Verify if the newly deployed slave (mysql-3) have the same data set by following command.
```sh
kubectl -n mysql run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
 mysql -h mysql-3.mysql -e "SELECT * FROM test.messages"
```

It will show the same data that master has.
{{< output >}}
+--------------------------+
| message                  |
+--------------------------+
| hello, from mysql-client |
+--------------------------+
{{< /output >}}

Scale down replicas to 3 by following command.
```sh
kubectl -n mysql  scale statefulset mysql --replicas=3
```

You can see StatefulSet "mysql" scaled
{{< output >}}
statefulset "mysql" scaled
{{< /output >}}

{{% notice warning %}}
Note that scale in doesn't delete the data or PVCs attached to the pods. You have to delete them manually.
{{% /notice %}}
Check scale in is completed by following command.
```sh
kubectl -n mysql get pods -l app=mysql
```
{{< output >}}
NAME      READY     STATUS    RESTARTS   AGE
mysql-0   2/2       Running   0          1d
mysql-1   2/2       Running   0          1d
mysql-2   2/2       Running   0          35m
{{< /output >}}

Check `data-mysql-3`, `data-mysql-4` PVCs still exist by following command.
```sh
kubectl -n mysql  get pvc -l app=mysql
```
{{< output >}}
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-mysql-0   Bound     pvc-83e9dfeb-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-1   Bound     pvc-977e7806-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-2   Bound     pvc-b3009b02-e721-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            1d
data-mysql-3   Bound     pvc-de14acd8-e811-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            34m
data-mysql-4   Bound     pvc-e916c3ec-e812-11e8-86c5-069628ef0c9c   10Gi       RWO            mysql-gp2            26m
{{< /output >}}


#### Challenge
By default, deleting a `PersistentVolumeClaim` will delete its associated persistent volume. What if you wanted to keep the volume?

Change the reclaim policy of the `PersistentVolume` associated with `PersistentVolumeClaim` called "data-mysql-3" to "Retain". Please see [Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/) for help

{{% expand "Expand here to see the solution"%}}
Change the reclaim policy:

Find the PersistentVolume attached to the PersistentVolumeClaim `data-mysql-3`
```sh
export pv=$(kubectl -n mysql  get pvc data-mysql-3 -o json | jq --raw-output '.spec.volumeName')
echo data-mysql-3 PersistentVolume name: ${pv}
```

Now update the ReclaimPolicy
```sh
kubectl -n mysql patch pv ${pv} -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

Verify the ReclaimPolicy with this command.
```sh
kubectl get persistentvolume
```
```text
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   REASON   AGE
pvc-93799c6d-3fd4-11ea-94be-0aff3e98c5a0   10Gi       RWO            Retain           Bound    mysql/data-mysql-3   mysql-gp2               19m
pvc-a4a40181-3fd4-11ea-94be-0aff3e98c5a0   10Gi       RWO            Delete           Bound    mysql/data-mysql-4   mysql-gp2               19m
pvc-c3d09831-3fca-11ea-94be-0aff3e98c5a0   10Gi       RWO            Delete           Bound    mysql/data-mysql-0   mysql-gp2               89m
pvc-e17bef75-3fca-11ea-94be-0aff3e98c5a0   10Gi       RWO            Delete           Bound    mysql/data-mysql-1   mysql-gp2               88m
pvc-f22aed7c-3fca-11ea-94be-0aff3e98c5a0   10Gi       RWO            Delete           Bound    mysql/data-mysql-2   mysql-gp2               88m
```


Now, if you delete the PersistentVolumeClaim data-mysql-3, you can still see the EBS volume in your AWS EC2 console, with its state as "available".

Let's change the reclaim policy back to "Delete" to avoid orphaned volumes:
```sh
kubectl patch pv ${pv} -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
unset pv
```
{{% /expand %}}

Delete `data-mysql-3` and `data-mysql-4` with following commands.
```sh
kubectl -n mysql delete pvc data-mysql-3
kubectl -n mysql delete pvc data-mysql-4
```
{{< output >}}
persistentvolumeclaim "data-mysql-3" deleted
persistentvolumeclaim "data-mysql-4" deleted
{{< /output >}}

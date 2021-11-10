---
title: "Test Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 35
---
More followers can be added to the MySQL Cluster to increase read capacity. This can be done by running the following command.

```sh
kubectl -n mysql scale statefulset mysql --replicas=3
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
Waiting for 1 pods to be ready...
partitioned roll out complete: 3 new pods have been updated...
{{< /output >}}

{{% notice note %}}
It may take few minutes to launch all the pods.
{{% /notice %}}

Open another terminal to check loop if you closed it.

```sh
kubectl -n mysql run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\
   bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id,NOW()'; done"
```

You will see 3 servers are running.
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
{{< /output >}}

Verify if the newly deployed follower (mysql-2) have the same data set by following command.

```sh
kubectl -n mysql run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
 mysql -h mysql-2.mysql -e "SELECT * FROM test.messages"
```

It will show the same data that the leader has.
{{< output >}}
+--------------------------+
| message                  |
+--------------------------+
| hello, from mysql-client |
+--------------------------+
{{< /output >}}

Scale down replicas to 2 by running the following command.

```sh
kubectl -n mysql  scale statefulset mysql --replicas=2
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
{{< /output >}}

Check `data-mysql-2`  PVCs still exist by following command.

```sh
kubectl -n mysql  get pvc -l app=mysql
```

{{< output >}}
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-mysql-0   Bound    pvc-fdb74a5e-ba51-4ccf-925b-e64761575059   10Gi       RWO            mysql-gp2      18m
data-mysql-1   Bound    pvc-355b9910-c446-4f66-8da6-629989a34d9a   10Gi       RWO            mysql-gp2      17m
data-mysql-2   Bound    pvc-12c304e4-2b3e-4621-8521-0dc17f41d107   10Gi       RWO            mysql-gp2      9m35s
{{< /output >}}

## Challenge

By default, deleting a `PersistentVolumeClaim` will delete its associated persistent volume. What if you wanted to keep the volume?

Change the reclaim policy of the `PersistentVolume` associated with `PersistentVolumeClaim` called "data-mysql-2" to "Retain". Please see [Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/) for help

{{% expand "Expand here to see the solution"%}}
Change the reclaim policy:

Find the PersistentVolume attached to the PersistentVolumeClaim `data-mysql-2`

```sh
export pv=$(kubectl -n mysql  get pvc data-mysql-2 -o json | jq --raw-output '.spec.volumeName')
echo data-mysql-2 PersistentVolume name: ${pv}
```

Now update the ReclaimPolicy

```sh
kubectl -n mysql patch pv ${pv} -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

Verify the ReclaimPolicy with this command.

```sh
kubectl get persistentvolume
```

{{< output >}}
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   REASON   AGE
pvc-12c304e4-2b3e-4621-8521-0dc17f41d107   10Gi       RWO            Retain           Bound    mysql/data-mysql-2   mysql-gp2               9m51s
pvc-355b9910-c446-4f66-8da6-629989a34d9a   10Gi       RWO            Delete           Bound    mysql/data-mysql-1   mysql-gp2               18m
pvc-fdb74a5e-ba51-4ccf-925b-e64761575059   10Gi       RWO            Delete           Bound    mysql/data-mysql-0   mysql-gp2               18m
{{< /output >}}

Now, if you delete the PersistentVolumeClaim data-mysql-2, you can still see the EBS volume in your AWS EC2 console, with its state as "available".

Let's change the reclaim policy back to "Delete" to avoid orphaned volumes:

```sh
kubectl patch pv ${pv} -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
unset pv
```

{{% /expand %}}

Delete `data-mysql-2` with following commands.

```sh
kubectl -n mysql delete pvc data-mysql-2
```

{{< output >}}
persistentvolumeclaim "data-mysql-2" deleted
{{< /output >}}

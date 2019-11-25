---
title: "Test Failure"
date: 2018-08-07T08:30:11-07:00
weight: 30
---
#### Unhealthy container
MySQL container uses readiness probe by running mysql -h 127.0.0.1 -e 'SELECT 1' on the server to make sure MySQL server is still active.
Open a new terminal and simulate MySQL as being unresponsive by following command.
```
kubectl exec mysql-2 -c mysql -- mv /usr/bin/mysql /usr/bin/mysql.off
```
This command renames the /usr/bin/mysql command so that readiness probe can't find it. During the next health check, the pod should report one of it's containers is not healthy. This can be verified by following command.
```
kubectl get pod mysql-2
```
```
NAME      READY     STATUS    RESTARTS   AGE
mysql-2   1/2       Running   0          12m
```
**mysql-read** load balancer detects failures and takes action by not sending traffic to the failed container, @@server_id 102. You can check this by the loop running in separate window from previous section. The loop shows the following output.
```
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         101 | 2018-11-14 13:00:45 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2018-11-14 13:00:46 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         101 | 2018-11-14 13:00:47 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2018-11-14 13:00:48 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2018-11-14 13:00:49 |
+-------------+---------------------+
```
Revert back to its initial state at the previous terminal.
```
kubectl exec mysql-2 -c mysql -- mv /usr/bin/mysql.off /usr/bin/mysql
```
Check the status again to see that both containers are running and healthy
```
$ kubectl get pod -w mysql-2
```
```
NAME      READY     STATUS    RESTARTS   AGE
mysql-2   2/2       Running   0          5h
```
The loop in another terminal is now showing @@server_id 102 is back and all three servers are running.
Press Ctrl+C to stop watching.
#### Failed pod
To simulate a failed pod, delete mysql-2 pod by following command.
```
kubectl delete pod mysql-2
```
```
pod "mysql-2" deleted
```
StatefulSet controller recognizes failed pod and creates a new one to maintain the number of replicas with them same name and link to the same PersistentVolumeClaim.
```
$ kubectl get pod -w mysql-2
```
```
NAME      READY     STATUS        RESTARTS   AGE
mysql-2   2/2       Terminating   0          1d
mysql-2   0/2       Terminating   0         1d
mysql-2   0/2       Terminating   0         1d
mysql-2   0/2       Terminating   0         1d
mysql-2   0/2       Pending   0         0s
mysql-2   0/2       Pending   0         0s
mysql-2   0/2       Init:0/2   0         0s
mysql-2   0/2       Init:1/2   0         10s
mysql-2   0/2       PodInitializing   0         11s
mysql-2   1/2       Running   0         12s
mysql-2   2/2       Running   0         16s

```
Press Ctrl+C to stop watching.


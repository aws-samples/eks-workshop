---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 40
---
First delete the StatefulSet. This will also terminates the pods. 
It may take some while.
```
kubectl delete statefulset mysql
```
Verify there are no pods running by following command.
```
kubectl get pods -l app=mysql
```
```
No resources found.
```

Delete ConfigMap, Service and PVC by following command.
```
kubectl delete configmap,service,pvc -l app=mysql
```
```
configmap "mysql-config" deleted
service "mysql" deleted
service "mysql-read" deleted
persistentvolumeclaim "data-mysql-0" deleted
persistentvolumeclaim "data-mysql-1" deleted
persistentvolumeclaim "data-mysql-2" deleted
```
#### Congratulation! You've finished the StatefulSets lab.

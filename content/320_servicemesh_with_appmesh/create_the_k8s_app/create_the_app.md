---
title: "Create DJ App"
date: 2018-08-07T08:30:11-07:00
weight: 60
---

Let's create the DJ App!

To create the prod namespace, issue the following command:

```
kubectl apply -f 1_create_the_initial_architecture/1_prod_ns.yaml
```

Output should be similar to:

```
namespace/prod created
```

Now that we have the prod namespace created, we'll deploy the DJ App (dj, metal, and jazz microservices) into it.

Create the DJ App deployment in the prod namespace by issuing the following command:

```
kubectl apply -nprod -f 1_create_the_initial_architecture/1_initial_architecture_deployment.yaml
```

Output should be similar to:

```
deployment.apps "dj" created
deployment.apps "metal-v1" created
deployment.apps "jazz-v1" created
```

Create the services that front these deployments by issuing the following command:

```
kubectl apply -nprod -f 1_create_the_initial_architecture/1_initial_architecture_services.yaml
```

Output should be similar to:

```
service "dj" created
service "metal-v1" created
service "jazz-v1" created
```

Let's verify everything has been setup correctly by getting all resources from the prod namespace.  Issue this command:

```
kubectl get all -nprod
```

Output should display dj, jazz, and metal pods, services, deployments, and replica sets, similar to:

```
NAME                            READY   STATUS    RESTARTS   AGE
pod/dj-5b445fbdf4-qf8sv         1/1     Running   0          1m
pod/jazz-v1-644856f4b4-mshnr    1/1     Running   0          1m
pod/metal-v1-84bffcc887-97qzw   1/1     Running   0          1m

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/dj         ClusterIP   10.100.247.180   <none>        9080/TCP   15s
service/jazz-v1    ClusterIP   10.100.157.174   <none>        9080/TCP   15s
service/metal-v1   ClusterIP   10.100.187.186   <none>        9080/TCP   15s

NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dj         1         1         1            1           1m
deployment.apps/jazz-v1    1         1         1            1           1m
deployment.apps/metal-v1   1         1         1            1           1m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/dj-5b445fbdf4         1         1         1       1m
replicaset.apps/jazz-v1-644856f4b4    1         1         1       1m
replicaset.apps/metal-v1-84bffcc887   1         1         1       1m

```

Once you've verified all resources have been created correctly in the prod namespace, next we'll test out this initial version of the DJ App.

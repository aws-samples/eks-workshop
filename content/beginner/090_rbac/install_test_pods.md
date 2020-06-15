---
title: "Install Test Pods"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 11
---

In this tutorial, we're going to demonstrate how to provide limited access to pods running in the rbac-test namespace for a user named rbac-user.

To do that, let's first create the rbac-test namespace, and then install nginx into it:

```
kubectl create namespace rbac-test
kubectl create deploy nginx --image=nginx -n rbac-test
```

To verify the test pods were properly installed, run:

```
kubectl get all -n rbac-test
```

Output should be similar to:

{{< output >}}
NAME                       READY   STATUS    RESTARTS   AGE
pod/nginx-5c7588df-8mvxx   1/1     Running   0          48s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           48s

NAME                             DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-5c7588df   1         1         1       48s
{{< /output >}}

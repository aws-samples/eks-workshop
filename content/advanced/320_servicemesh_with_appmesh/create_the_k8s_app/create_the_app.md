---
title: "Create DJ App"
date: 2018-08-07T08:30:11-07:00
weight: 60
---

Let's create the DJ App!

![dj app 1](/images/app_mesh_ga/djapp-1.png)

To create the `prod` namespace, issue the following command

```bash
kubectl apply -n prod \
  -f 1_create_the_initial_architecture/1_prod_ns.yaml
```

The output should be similar to:

{{< output >}}
namespace/prod created
{{< /output >}}

Now that we have created the namespace, we'll deploy the DJ App (`dj`, `metal`, and `jazz` microservices) and the services that front them.

```bash
kubectl apply -n prod \
  -f 1_create_the_initial_architecture/1_initial_architecture_deployment.yaml \
  -f 1_create_the_initial_architecture/1_initial_architecture_services.yaml
```

We can verify the deployed objects

```bash
kubectl -n prod get pods,deploy,service
```

Output should look like this

{{< output >}}
NAME                           READY   STATUS    RESTARTS   AGE
pod/dj-8d4fc6ccd-ntjnq         1/1     Running   0          7s
pod/jazz-v1-f94cdc64d-ql9rw    1/1     Running   0          7s
pod/metal-v1-654d4858f-dqjjx   1/1     Running   0          7s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/dj         1/1     1            1           7s
deployment.extensions/jazz-v1    1/1     1            1           7s
deployment.extensions/metal-v1   1/1     1            1           7s

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/dj         ClusterIP   10.100.11.220    <none>        9080/TCP   7s
service/jazz-v1    ClusterIP   10.100.7.223     <none>        9080/TCP   7s
service/metal-v1   ClusterIP   10.100.174.186   <none>        9080/TCP   7s
{{< /output >}}

Once you've verified all resources have been created correctly in the prod namespace, next we'll test out this initial version of the DJ App.

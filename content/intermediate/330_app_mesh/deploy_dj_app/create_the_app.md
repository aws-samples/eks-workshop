---
title: "Create DJ App"
date: 2018-08-07T08:30:11-07:00
weight: 60
---

Let's create the DJ App!

![dj app 1](/images/app_mesh_ga/djapp-1.png)

The application repo has all of the configuration YAML required to deploy the DJ App into its own `prod` namespace on your Kubernetes cluster.

```bash
kubectl apply -f 1_base_application/base_app.yaml
```

This will create the `prod` namespace as well as the `Deployments` and `Services` for the application. The output should be similar to:

{{< output >}}
namespace/prod created
deployment.apps/dj created
deployment.apps/metal-v1 created
deployment.apps/jazz-v1 created
service/dj created
service/metal-v1 created
service/jazz-v1 created
{{< /output >}}

You can now verify that the objects were all created successfully and the application is up and running.

```bash
kubectl -n prod get all
```

{{< output >}}
NAME                            READY   STATUS    RESTARTS   AGE
pod/dj-6bf5fb7f45-qkhv7         1/1     Running   0          42s
pod/jazz-v1-6f688dcbf9-djb9h    1/1     Running   0          41s
pod/metal-v1-566756fbd6-8k2rs   1/1     Running   0          41s

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/dj         ClusterIP   10.100.42.60     <none>        9080/TCP   41s
service/jazz-v1    ClusterIP   10.100.192.113   <none>        9080/TCP   40s
service/metal-v1   ClusterIP   10.100.238.120   <none>        9080/TCP   40s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dj         1/1     1            1           42s
deployment.apps/jazz-v1    1/1     1            1           41s
deployment.apps/metal-v1   1/1     1            1           41s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/dj-6bf5fb7f45         1         1         1       43s
replicaset.apps/jazz-v1-6f688dcbf9    1         1         1       42s
replicaset.apps/metal-v1-566756fbd6   1         1         1       42s
{{< /output >}}

Once you've verified everything is looking good in the `prod` namespace, you're ready to test out this initial version of the DJ App.

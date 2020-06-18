---
title: "Create the Meshed Application"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

Using the YAML we just reviewed, apply the meshed application resources with kubectl.

```bash
kubectl apply -f 2_meshed_application/meshed_app.yaml
```

{{< output >}}
namespace/prod configured
mesh.appmesh.k8s.aws/dj-app created
virtualnode.appmesh.k8s.aws/dj created
virtualservice.appmesh.k8s.aws/jazz created
virtualservice.appmesh.k8s.aws/metal created
virtualrouter.appmesh.k8s.aws/jazz-router created
virtualrouter.appmesh.k8s.aws/metal-router created
virtualnode.appmesh.k8s.aws/jazz-v1 created
virtualnode.appmesh.k8s.aws/metal-v1 created
service/jazz created
service/metal created
namespace/prod configured
{{< /output >}}

This creates the Kubernetes objects, and the App Mesh controller in turn creates resources within AWS App Mesh for you.

You can see that your mesh object was created using `kubectl`.

```bash
kubectl get meshes
```

{{< output >}}
NAME     ARN                                                  AGE
dj-app   arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app   119s
{{< /output >}}

You can also see that the mesh was created in App Mesh using the `aws` CLI.

```bash
aws appmesh list-meshes
```

{{< output >}}
{
   "meshes" : [
      {
         "arn" : "arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app",
         "meshName" : "dj-app",
         "version" : 1,
         "meshOwner" : "1234567890",
         "createdAt" : "2020-06-18T10:01:21.411000-04:00",
         "resourceOwner" : "1234567890",
         "lastUpdatedAt" : "2020-06-18T10:01:21.411000-04:00"
      }
   ]
}
{{< /output >}}

Examine the objects within the `prod` namespace and you will see your App Mesh resources along with your native Kubernetes objects.

```bash
 kubectl get all -n prod
```

{{< output >}}
NAME                            READY   STATUS    RESTARTS   AGE
pod/dj-6bf5fb7f45-qkhv7         1/1     Running   0          18m
pod/jazz-v1-6f688dcbf9-djb9h    1/1     Running   0          18m
pod/metal-v1-566756fbd6-8k2rs   1/1     Running   0          18m

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/dj         ClusterIP   10.100.42.60     <none>        9080/TCP   18m
service/jazz       ClusterIP   10.100.134.233   <none>        9080/TCP   17s
service/jazz-v1    ClusterIP   10.100.192.113   <none>        9080/TCP   18m
service/metal      ClusterIP   10.100.175.238   <none>        9080/TCP   17s
service/metal-v1   ClusterIP   10.100.238.120   <none>        9080/TCP   18m

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dj         1/1     1            1           18m
deployment.apps/jazz-v1    1/1     1            1           18m
deployment.apps/metal-v1   1/1     1            1           18m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/dj-6bf5fb7f45         1         1         1       18m
replicaset.apps/jazz-v1-6f688dcbf9    1         1         1       18m
replicaset.apps/metal-v1-566756fbd6   1         1         1       18m

NAME                                   ARN                                                                            AGE
virtualnode.appmesh.k8s.aws/dj         arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app/virtualNode/dj_prod         19s
virtualnode.appmesh.k8s.aws/jazz-v1    arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app/virtualNode/jazz-v1_prod    17s
virtualnode.appmesh.k8s.aws/metal-v1   arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app/virtualNode/metal-v1_prod   17s

NAME                                   ARN                                                                                              AGE
virtualservice.appmesh.k8s.aws/jazz    arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app/virtualService/jazz.prod.svc.cluster.local    19s
virtualservice.appmesh.k8s.aws/metal   arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app/virtualService/metal.prod.svc.cluster.local   18s

NAME                                         ARN                                                                                  AGE
virtualrouter.appmesh.k8s.aws/jazz-router    arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app/virtualRouter/jazz-router_prod    19s
virtualrouter.appmesh.k8s.aws/metal-router   arn:aws:appmesh:us-west-2:1234567890:mesh/dj-app/virtualRouter/metal-router_prod   19s
{{< /output >}}


---
title: "Canary Testing with a v2"
date: 2018-08-07T08:30:11-07:00
weight: 90
---

A canary release is a method of slowly exposing a new version of software. The theory behind it is that by serving the new version of the software initially to say, 5% of requests, if there is a problem, the problem only impacts a very small percentage of users before its discovered and rolled back.

So now back to our DJ App scenario, `metal-v2` and `jazz-v2` services are out, and they now include the city each artist is from in the response.

Let's see how we can release these new versions in a canary fashion using `AWS App Mesh`.

When we're complete, requests to `metal` and `jazz` will be distributed in a weighted fashion to both the v1 and v2 versions, with 95% going to the current prod v1 and 5% going to our release candidate v2.

![App Mesh](/images/app_mesh_ga/140-v2-mesh.png)

### v2 Services

YAML for this step can be found in the `3_canary_new_version` directory. First, let's look at the new v2 deployments and services. Below is jazz-v2, for example.

{{< output >}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jazz-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jazz
      version: v2
  template:
    metadata:
      labels:
        app: jazz
        version: v2
    spec:
      serviceAccountName: prod-proxies
      containers:
        - name: jazz
          image: "672518094988.dkr.ecr.us-west-2.amazonaws.com/hello-world:v1.0"
          ports:
            - containerPort: 9080
          env:
            - name: "HW_RESPONSE"
              value: "[\"Astrud Gilberto (Bahia, Brazil)\",\"Miles Davis (Alton, Illinois)\"]"
---
apiVersion: v1
kind: Service
metadata:
  name: jazz-v2
  labels:
    app: jazz
    version: v2
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: jazz
    version: v2
---
{{< /output >}}

You can see our exciting new feature enhancement is ready to deploy.

### Canary for v2

If we deploy our new service versions into `prod` right now, we will not have any traffic routed to them. To achieve this, we need to define `VirtualNode`s for each new version, as well as apply an update to our existing `VirtualRouter`s to send 5% of traffic to the new version.

We will use App Mesh's `weightedTargets` route feature to configure this logic.

{{< output >}}
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualNode
metadata:
  name: jazz-v2
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: jazz
      version: v2
  listeners:
    - portMapping:
        port: 9080
        protocol: http
      healthCheck:
        protocol: http
        path: '/ping'
        healthyThreshold: 2
        unhealthyThreshold: 2
        timeoutMillis: 2000
        intervalMillis: 5000
  serviceDiscovery:
    dns:
      hostname: jazz-v2.prod.svc.cluster.local
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualRouter
metadata:
  name: jazz-router
  namespace: prod
spec:
  listeners:
    - portMapping:
        port: 9080
        protocol: http
  routes:
    - name: jazz-route
      httpRoute:
        match:
          prefix: /
        action:
          weightedTargets:
            - virtualNodeRef:
                name: jazz-v1
              weight: 95
            - virtualNodeRef:
                name: jazz-v2
              weight: 5
---
{{< /output >}}

With this, our configuration changes are complete and ready to deploy. Apply these changes now with `kubectl`.

```bash
kubectl apply -f 3_canary_new_version/v2_app.yaml
```

{{< output >}}
virtualrouter.appmesh.k8s.aws/jazz-router configured
virtualrouter.appmesh.k8s.aws/metal-router configured
virtualnode.appmesh.k8s.aws/jazz-v2 created
virtualnode.appmesh.k8s.aws/metal-v2 created
deployment.apps/jazz-v2 created
deployment.apps/metal-v2 created
service/jazz-v2 created
service/metal-v2 created
{{< /output >}}

Verify the status of your new and existing Kubernetes objects.

```bash
kubectl -n prod get deployments,services,virtualnodes,virtualrouters
```

{{< output >}}
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dj         1/1     1            1           139m
deployment.apps/jazz-v1    1/1     1            1           139m
deployment.apps/metal-v1   1/1     1            1           139m

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/dj         ClusterIP   10.100.42.60     <none>        9080/TCP   139m
service/jazz       ClusterIP   10.100.134.233   <none>        9080/TCP   121m
service/jazz-v1    ClusterIP   10.100.192.113   <none>        9080/TCP   139m
service/metal      ClusterIP   10.100.175.238   <none>        9080/TCP   121m
service/metal-v1   ClusterIP   10.100.238.120   <none>        9080/TCP   139m

NAME                                   ARN                                                                            AGE
virtualnode.appmesh.k8s.aws/dj         arn:aws:appmesh:us-west-2:510431938379:mesh/dj-app/virtualNode/dj_prod         121m
virtualnode.appmesh.k8s.aws/jazz-v1    arn:aws:appmesh:us-west-2:510431938379:mesh/dj-app/virtualNode/jazz-v1_prod    121m
virtualnode.appmesh.k8s.aws/jazz-v2    arn:aws:appmesh:us-west-2:510431938379:mesh/dj-app/virtualNode/jazz-v2_prod    37s
virtualnode.appmesh.k8s.aws/metal-v1   arn:aws:appmesh:us-west-2:510431938379:mesh/dj-app/virtualNode/metal-v1_prod   121m
virtualnode.appmesh.k8s.aws/metal-v2   arn:aws:appmesh:us-west-2:510431938379:mesh/dj-app/virtualNode/metal-v2_prod   37s

NAME                                         ARN                                                                                  AGE
virtualrouter.appmesh.k8s.aws/jazz-router    arn:aws:appmesh:us-west-2:510431938379:mesh/dj-app/virtualRouter/jazz-router_prod    121m
virtualrouter.appmesh.k8s.aws/metal-router   arn:aws:appmesh:us-west-2:510431938379:mesh/dj-app/virtualRouter/metal-router_prod   121m
{{< /output >}}

Dig in a little deeper to see the updated `Route` configuration for the 'jazz-router' virtual router.

```bash
kubectl -n prod describe virtualrouters jazz-router
```

{{< output >}}
  ..
  Routes:
    Http Route:
      Action:
        Weighted Targets:
          Virtual Node Ref:
            Name:  jazz-v1
          Weight:  95
          Virtual Node Ref:
            Name:  jazz-v2
          Weight:  5
      Match:
        Prefix:  /
    Name:        jazz-route
  ..
{{{< /output >}}

Here you can see that it is configured to route 95% of traffic to the v1 version of the service, and 5% to v2 for canary testing. Let's test this out.

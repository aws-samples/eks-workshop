---
title: "More Practical use-cases"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---

More Practical use-cases `AntiAffinity` can be even more useful when they are used with higher level collections such as `ReplicaSets`, `StatefulSets`, `Deployments`, etc. One can easily configure that a set of workloads should be co-located in the same defined topology, eg., the same node.

### Always co-located in the same node

In a three node cluster, a web application has in-memory cache such as redis. We want the web-servers to be co-located with the cache as much as possible.

Here is the YAML snippet of a simple redis deployment with three replicas and selector label `app=store`. The deployment has `PodAntiAffinity` configured to ensure the scheduler does not co-locate replicas on a single node.

```bash
cat <<EoF > ~/environment/redis-with-node-affinity.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cache
spec:
  selector:
    matchLabels:
      app: store
  replicas: 3
  template:
    metadata:
      labels:
        app: store
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: redis-server
        image: redis:3.2-alpine
EoF
```

The below YAML snippet of the web-server deployment has `podAntiAffinity` and `podAffinity` configured. This informs the scheduler that all its replicas are to be co-located with pods that have selector label `app=store`. This will also ensure that each web-server replica does not co-locate on a single node.

```bash
cat <<EoF > ~/environment/web-with-node-affinity.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
spec:
  selector:
    matchLabels:
      app: web-store
  replicas: 3
  template:
    metadata:
      labels:
        app: web-store
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-store
            topologyKey: "kubernetes.io/hostname"
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: web-app
        image: nginx:1.12-alpine
EoF
```

Let's apply this Deployments

```bash
kubectl apply -f ~/environment/redis-with-node-affinity.yaml
kubectl apply -f ~/environment/web-with-node-affinity.yaml
```

If we create the above two deployments, our three node cluster should look like below.

` node-1 - webserver-1 - cache-1 `

` node-2 - webserver-2 - cache-2 `

` node-3 - webserver-3 - cache-3 `
  
As you can see, all the 3 replicas of the web-server are automatically co-located with the cache as expected.

```bash
# We will use --sort-by to filter by nodes name
 kubectl get pods -o wide --sort-by='.spec.nodeName'
```

{{< output >}}
NAME                          READY   STATUS    RESTARTS   AGE     IP                NODE                                            NOMINATED NODE   READINESS GATES
redis-cache-d5f6b6855-pvnq9   1/1     Running   0          6m15s   192.168.105.235   ip-192-168-120-42.us-east-2.compute.internal    <none>           <none>
web-server-7886dfdc59-m4g2s   1/1     Running   0          6m14s   192.168.105.33    ip-192-168-120-42.us-east-2.compute.internal    <none>           <none>
redis-cache-d5f6b6855-2m58b   1/1     Running   0          6m15s   192.168.153.148   ip-192-168-149-120.us-east-2.compute.internal   <none>           <none>
web-server-7886dfdc59-f2wc7   1/1     Running   0          6m14s   192.168.150.168   ip-192-168-149-120.us-east-2.compute.internal   <none>           <none>
redis-cache-d5f6b6855-9574n   1/1     Running   0          6m15s   192.168.162.182   ip-192-168-168-227.us-east-2.compute.internal   <none>           <none>
web-server-7886dfdc59-5r7ww   1/1     Running   0          6m14s   192.168.185.74    ip-192-168-168-227.us-east-2.compute.internal   <none>           <none>
{{< /output >}}

---
title: "Sidecar Injection"
date: 2020-01-27T08:30:11-07:00
weight: 70
---

Recall that to join the mesh, each pod will need an Envoy proxy sidecar container. We have enabled automatic sidecar injection on the `prodcatalog-ns` namespace, but this was done after initial pod creation. Currently, your pods each have one container running.

```bash
kubectl get pods -n prodcatalog-ns -o wide
```

{{< output >}}
NAME                                 READY   STATUS    RESTARTS   AGE   IP               NODE                                                   NOMINATED NODE   READINESS GATES
pod/frontend-node-77d64585d4-xxxx   1/1     Running   0          13h   192.168.X.6     ip-192-168-X-X.us-west-2.compute.internal           <none>           <none>
pod/prodcatalog-98f7c5f87-xxxxx      1/1     Running   0          13h   192.168.X.17   fargate-ip-192-168-X-X.us-west-2.compute.internal   <none>           <none>
pod/proddetail-5b558df99d-xxxxx      1/1     Running   0          18h   192.168.24.X   ip-192-168-X-X.us-west-2.compute.internal            <none>           <none>
{{< /output >}}

To inject sidecar proxies for these pods, simply restart the deployments. The controller will handle the rest.

```bash
kubectl -n prodcatalog-ns rollout restart deployment prodcatalog

kubectl -n prodcatalog-ns rollout restart deployment proddetail 

kubectl -n prodcatalog-ns rollout restart deployment frontend-node
```

Get the Pod details. You should see 3 containers in each pod `main application container`, `envoy sidecar container` and `xray sidecar container`

{{% notice info %}}
It takes 4 to 6 minutes to restart the Fargate Pod
{{% /notice %}}

```bash
kubectl get pods -n prodcatalog-ns -o wide
```

{{< output >}}
NAME                                 READY   STATUS    RESTARTS   AGE   IP               NODE                                                   NOMINATED NODE   READINESS GATES
pod/frontend-node-77d64585d4-xxxx   3/3     Running   0          13h   192.168.X.6     ip-192-168-X-X.us-west-2.compute.internal           <none>           <none>
pod/prodcatalog-98f7c5f87-xxxxx      3/3     Running   0          13h   192.168.X.17   fargate-ip-192-168-X-X.us-west-2.compute.internal   <none>           <none>
pod/proddetail-5b558df99d-xxxxx      3/3     Running   0          18h   192.168.24.X   ip-192-168-X-X.us-west-2.compute.internal            <none>           <none>                                                                       3000/TCP       44h   app=proddetail,version=v1
{{< /output >}}

#### Get Running containers from pod
You can see that there are two sidecar containers `envoy` and `xray-daemon` along with application container `frontend-node`

```bash
POD=$(kubectl -n prodcatalog-ns get pods -o jsonpath='{.items[0].metadata.name}')
kubectl -n prodcatalog-ns get pods ${POD} -o jsonpath='{.spec.containers[*].name}'; echo
```
{{< output >}}
frontend-node envoy xray-daemon
{{< /output >}}

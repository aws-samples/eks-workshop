---
title: "Sidecar Injection"
date: 2020-01-27T08:30:11-07:00
weight: 70
---

For a pod in your application to join a mesh, it must have an Envoy proxy container running sidecar within the pod. This establishes the data plane that AWS App Mesh controls. So we must run an Envoy container within each pod of the Product Catalog App deployment. For example:

![App Mesh](/images/app_mesh_fargate/pcapp.png)

This can be accomplished a few different ways:

* Before installing the application, you can modify the Product Catalog App `Deployment` container specs to include App Mesh sidecar containers and set a few required configuration elements and environment variables. When pods are deployed, they would run the sidecar.

* After installing the application, you can patch each `Deployment` to include the sidecar container specs. Upon applying this patch, the old pods would be torn down, and the new pods would come up with the sidecar.

* You can enable the AWS App Mesh Sidecar Injector in the meshed namespace, which watches for new pods to be created and automatically adds the sidecar container and required configuration to the pods as they are deployed.

In this tutorial, we will use the third option and enable automatic sidecar injection for our meshed pods. We have enabled automatic sidecar injection by adding label `Labels: appmesh.k8s.aws/sidecarInjectorWebhook=enabled` on the `prodcatalog-ns` namespace when we created the mesh resources in [previous chapter](/advanced/330_servicemesh_using_appmesh/port_to_app_mesh/create_meshed_app/), but this was done after initial pod creation. Currently, our pods each have one container running.

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
We can see that there are two sidecar containers `envoy` and `xray-daemon` along with application container `frontend-node`

```bash
POD=$(kubectl -n prodcatalog-ns get pods -o jsonpath='{.items[0].metadata.name}')
kubectl -n prodcatalog-ns get pods ${POD} -o jsonpath='{.spec.containers[*].name}'; echo
```
{{< output >}}
frontend-node envoy xray-daemon
{{< /output >}}

---
title: "Create the Virtual Services"
date: 2018-08-07T08:30:11-07:00
weight: 60
---

The next step is to create the two `AWS App Mesh` Virtual Services that will intercept and route requests made to jazz and metal.

To accomplish this, execute the following command:

```bash
kubectl apply -n prod -f 4_create_initial_mesh_components/virtual-services.yaml
```

Output should be similar to:

{{< output >}}
virtualservice.appmesh.k8s.aws/jazz.prod.svc.cluster.local created
virtualservice.appmesh.k8s.aws/metal.prod.svc.cluster.local created
{{< /output >}}

If we inspect the YAML we just applied, we'll see that we've created two VirtualService resources:

* Requests made to `jazz.prod.svc.cluster.local` will routed to the `VirtualNode` `jazz-v1`.
* Requests made to `metal.prod.svc.cluster.local` will be routed to the `VirtualNode` `metal-v1`.

{{< output >}}
apiVersion: appmesh.k8s.aws/v1beta1
kind: VirtualService
metadata:
  name: jazz.prod.svc.cluster.local
  namespace: prod
spec:
  meshName: dj-app
  virtualRouter:
    name: jazz-router
  routes:
    - name: jazz-route
      http:
        match:
          prefix: /
        action:
          weightedTargets:
            - virtualNodeName: jazz-v1
              weight: 100

---
apiVersion: appmesh.k8s.aws/v1beta1
kind: VirtualService
metadata:
  name: metal.prod.svc.cluster.local
  namespace: prod
spec:
  meshName: dj-app
  virtualRouter:
    name: metal-router
  routes:
    - name: metal-route
      http:
        match:
          prefix: /
        action:
          weightedTargets:
            - virtualNodeName: metal-v1
              weight: 100
{{< /output >}}

{{% notice note %}}
Remember to use fully qualified DNS names for the the Virtual Service's metadata.name field to prevent the chance of name collisions when using App Mesh cross-cluster.
{{% /notice %}}

With these Virtual Services defined, to access them by name, clients (in our case, the dj container) will first perform a DNS lookup request to `jazz.prod.svc.cluster.local`, or `metal.prod.svc.cluster.local` before making the request.

If the `dj` container (or any other client) cannot resolve that name to an IP, the subsequent HTTP request will fail with a name lookup error.

Our other physical services (`jazz-v1`, `metal-v1`, `dj`) are defined as physical kubernetes services, and therefore have discoverable names and IPs. However, these Virtual Services don't (yet).

```bash
kubectl -n prod get service
```

{{< output >}}
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
dj         ClusterIP   10.100.11.220    <none>        9080/TCP   107m
jazz-v1    ClusterIP   10.100.7.223     <none>        9080/TCP   107m
metal-v1   ClusterIP   10.100.174.186   <none>        9080/TCP   107m
{{< /output >}}

To provide the the jazz and metal virtual services with resolvable IPs and hostnames, we'll define them as kubernetes services that do not map to any deployments or pods;   we'll do this by creating them as k8s services [without defining selectors](https://kubernetes.io/docs/concepts/services-networking/service/#services-without-selectors) for them.   

Since App Mesh will be intercepting and routing requests made for them, they won't need to map to any pods or deployments on the k8s-side.

To register the placeholder names and IPs for these Virtual Services, execute the following:

```bash
kubectl -n prod create -f 4_create_initial_mesh_components/metal_and_jazz_placeholder_services.yaml
```

Output should be similar to:
{{< output >}}
service/jazz created
service/metal created
{{< /output >}}

We can now use `kubectl` to get the registered metal and jazz Virtual Services:

```bash
kubectl -n prod get virtualservices
```

{{< output >}}
NAME                           AGE
jazz.prod.svc.cluster.local    8m23s
metal.prod.svc.cluster.local   8m23ss
{{< /output >}}

along with the Virtual Service placeholder IPs, and physical service IPs:

```bash
kubectl -n prod get service
```

yields:
{{< output >}}
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
dj         ClusterIP   10.100.11.220    <none>        9080/TCP   113m
jazz       ClusterIP   10.100.165.85    <none>        9080/TCP   50s
jazz-v1    ClusterIP   10.100.7.223     <none>        9080/TCP   113m
metal      ClusterIP   10.100.186.225   <none>        9080/TCP   50s
metal-v1   ClusterIP   10.100.174.186   <none>        9080/TCP   113m
{{< /output >}}

As such, when name lookup requests are made to our Virtual Services, alongside their physical service counterparts, they will resolve.

---
title: "Create the Virtual Nodes"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

With the foundational mesh component created, we'll continue onward to define the App Mesh Virtual Node and Virtual Service components.

All services (physical or virtual) that will interact in any way with each other in App Mesh must first be defined as Virtual Node objects.  Abstracting out services as Virtual Nodes helps App Mesh build rulesets around inter-service communication. In addition, as we define Virtual Service objects, Virtual Nodes are referenced as the ingress and target endpoints for those Virtual Services.  Because of this, it makes sense to define the Virtual Nodes first.

Based on our first App Mesh-enabled architecture, our physical service dj will make requests to two new Virtual Services, metal, and jazz.  Metal and jazz will route requests to the physical services metal-v1, and jazz-v1 accordingly.

![App Mesh](/images/app_mesh_ga/135-v1-mesh.png)


Since there will be five services involved in this configuration, we'll need to define five Virtual Nodes.

We'll first define the Virtual Nodes that will represent our virtual jazz and metal services.  To define these services as App Mesh Virtual Nodes, enter the following:

```
kubectl create -f 4_create_initial_mesh_components/nodes_representing_virtual_services.yaml
```

You should see output similar to:

```
virtualnode.appmesh.k8s.aws/metal created
virtualnode.appmesh.k8s.aws/jazz created
```

If you open the YAML up in your favorite editor, you'll notice a few things about these Virtual Nodes.  They're both similar, but for purposes of this tutorial, let's examine just the metal.prod.svc.cluster.local VirtualNode:

```
apiVersion: appmesh.k8s.aws/v1beta1
kind: VirtualNode
metadata:
  name: metal
  namespace: prod
spec:
  meshName: dj-app
  listeners:
    - portMapping:
        port: 9080
        protocol: http
  serviceDiscovery:
    dns:
      hostName: metal.prod.svc.cluster.local

...
```

According to this YAML, we see that this Virtual Node points to a service (spec.serviceDiscovery.dns.hostName: metal.prod.svc.cluster.local) that listens on a given port for requests (spec.listeners.portMapping.port: 9080).

We'll finish up creating the dj, metal-v1, and jazz-v1 Virtual Nodes next.  Run the following command:

```
kubectl create -nprod -f 4_create_initial_mesh_components/nodes_representing_physical_services.yaml
```

Output should be similar to:

```
virtualnode.appmesh.k8s.aws/dj created
virtualnode.appmesh.k8s.aws/jazz-v1 created
virtualnode.appmesh.k8s.aws/metal-v1 created
```

If you view the YAML we used to create the above Virtual Nodes, you'll notice jazz-v1 and metal-v1 are very similar (aside from name) to the previous metal and jazz Virtual Nodes we created earlier.  The one key difference is to be found in the dj Virtual Node, which contains a backends attribute:

```
apiVersion: appmesh.k8s.aws/v1beta1
kind: VirtualNode
metadata:
  name: dj
  namespace: prod
spec:
  meshName: dj-app
  listeners:
    - portMapping:
        port: 9080
        protocol: http
  serviceDiscovery:
    dns:
      hostName: dj.prod.svc.cluster.local
  backends:
    - virtualService:
        virtualServiceName: jazz.prod.svc.cluster.local
    - virtualService:
        virtualServiceName: metal.prod.svc.cluster.local
```

The backend attribute specifies that dj is allowed to make requests to the jazz and metal Virtual Services only.

We've now created five Virtual Nodes which can be view with the following command:

```
kubectl get virtualnodes -nprod
```

yielding:

```
NAME            AGE
dj              6m
jazz            3h
jazz-v1         6m
metal           3h
metal-v1        6m
```

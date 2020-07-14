---
title: "Mesh Resources and Design"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

To port the DJ App to App Mesh, you will need create a mesh as well as the various mesh components. You'll also apply labels to the `prod` namespace to affiliate your new mesh with it, and to enable automatic sidecar injection for pods within it.

### App Mesh Resources

Kubernetes application objects that run within App Mesh must be defined as `Virtual Nodes`. This provides App Mesh an abstraction to objects such as Kubernetes Deployments and Services, and provides endpoints for communication and routing configuration.

App Mesh also provides the `Virtual Service` construct which allows you to specify a logical service path for application traffic. In this example, they send traffic to `Virtual Routers`, which then route traffic to the `Virtual Nodes`.

In the image below you see DJ App running within App Mesh. Each of the services (`dj`, `metal-v1`, and `jazz-v1`) has a virtual node defined, and each music category has a virtual service (`metal` and `jazz`). These virtual services send traffic to virtual routers within the mes, which in turn specify routing rules. This drives traffic to their respective virtual nodes and ultimately to the service endpoints within Kubernetes. 

![App Mesh](/images/app_mesh_ga/135-v1-mesh.png)

You'll find the YAML which specify these resources in the application repo's `2_meshed_application` directory. 

Looking at the YAML, you can see we've added the required labels to the `prod` namespace and specified our mesh named `dj-app`.

{{< output >}}
---
apiVersion: v1
kind: Namespace
metadata:
  name: prod
  labels:
    mesh: dj-app
    appmesh.k8s.aws/sidecarInjectorWebhook: enabled
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: Mesh
metadata:
  name: dj-app
spec:
  namespaceSelector:
    matchLabels:
      mesh: dj-app
---
{{< /output >}}

Included are the specifications for the App Mesh resources shown in the image above. For example, here is the `dj` service's `VirtualNode` specification.

{{< output >}}
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualNode
metadata:
  name: dj
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: dj
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
  backends:
    - virtualService:
        virtualServiceRef:
          name: jazz
    - virtualService:
        virtualServiceRef:
          name: metal
  serviceDiscovery:
    dns:
      hostname: dj.prod.svc.cluster.local
---
{{< /output >}}

Note that it uses a `podSelector` to identify which `Pods` are members of this virtual node, as well as a pointer to the dj `Service`.

There are also `VirtualService` and `VirtualRouter` specifications for each of the music categories, establishing traffic routing to their respective endpoints. This is accomplished by adding `Route`s which point to the `jazz-v1` and `metal-v1` virtual nodes.

Shown here is the jazz virtual service and virtual router.

{{< output >}}
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualService
metadata:
  name: jazz
  namespace: prod
spec:
  awsName: jazz.prod.svc.cluster.local
  provider:
    virtualRouter:
      virtualRouterRef:
        name: jazz-router
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
              weight: 100
---
{{< /output >}}

With the basic constructs understood, it's time to create the mesh and its resources.

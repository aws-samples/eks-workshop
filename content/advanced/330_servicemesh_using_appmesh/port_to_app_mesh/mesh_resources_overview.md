---
title: "Mesh Resources and Design"
date: 2020-01-27T08:30:11-07:00
weight: 10
---

#### App Mesh Design
![App Mesh](/images/app_mesh_fargate/meshify.png)

In the image above you see all the services in Product Catalog Application are running within App Mesh. 
Each of the services  has a VirtualNode defined (`frontend-node`, `prodcatalog`, and `proddetail-v1`), as well as VirtualService (`fontend-node`, `prodcatalog` and `proddetail`). 
These VirtualServices send traffic to VirtualRouters within the mesh, which in turn specify routing rules. 
This drives traffic to their respective VirtualNodes and ultimately to the service endpoints within Kubernetes. 

##### How will it be different using App Mesh?

* Functionally, the mesh-enabled version will do exactly what the current version does; 
    * requests made by `frontend-node` will be served by the `prodcatalog` backend service; 
    * requests made by `prodcatalog` will be served by the `proddetail-v1` backend service;   
* The difference will be that we'll use `AWS App Mesh` to create new Virtual Services called `prodcatalog` and `proddetail`.
    * Requests made by `frontend-node` service will logically send traffic to `VirtualRouter` instances which will be configured to route traffic to the service endpoints within your cluster, to `prodcatalog`.
    * Requests made by `prodcatalog` service will logically send traffic to `VirtualRouter` instances which will be configured to route traffic to the service endpoints within your cluster, to `proddetail-v1`.

#### App Mesh Resources

##### Mesh
To port the Product Catalog Apps to App Mesh, first you will need create a mesh. 
You'll also apply labels to the `prodcatalog-ns` namespace to affiliate your new mesh with it, and to enable automatic sidecar injection for pods within it. 
Also add the the gateway label which we will use in next chapter for setting up VirtualGateway.
Looking at the section of [mesh.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/mesh.yaml) shown below, you can see we've added the required labels to the `prodcatalog-ns` namespace and specified our mesh named `prodcatalog-mesh`.

{{< output >}}
---
apiVersion: v1
kind: Namespace
metadata:
  name: prodcatalog-ns
  labels:
    mesh: prodcatalog-mesh
    gateway: ingress-gw
    appmesh.k8s.aws/sidecarInjectorWebhook: enabled
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: Mesh
metadata:
  name: prodcatalog-mesh
spec:
  namespaceSelector:
    matchLabels:
      mesh: prodcatalog-mesh
---
{{< /output >}}

##### VirtualNode
Kubernetes application objects that run within App Mesh must be defined as `VirtualNode`. This provides App Mesh an abstraction to objects such as Kubernetes Deployments and Services, and provides endpoints for communication and routing configuration.
Looking at the [meshed_app.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/meshed_app.yaml), below is the `frontend-node` service's `VirtualNode` specification.

{{< output >}}
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualNode
metadata:
  name: frontend-node
  namespace: prodcatalog-ns
spec:
  podSelector:
    matchLabels:
      app: frontend-node
      version: v1
  listeners:
    - portMapping:
        port: 9000
        protocol: http
  backends:
    - virtualService:
        virtualServiceRef:
          name: prodcatalog
    - virtualService:
        virtualServiceRef:
          name: prodsummary
  serviceDiscovery:
    dns:
      hostname: frontend-node.prodcatalog-ns.svc.cluster.local
  logging:
    accessLog:
      file:
        path: /dev/stdout
---
{{< /output >}}

Note that it uses a `podSelector` to identify which `Pods` are members of this VirtualNode, as well as a pointer to the frontend-node `Service`.

##### VirtualService and VirtualRouter
There are also VirtualService and VirtualRouter specifications for each of the product catalog detail versions, establishing traffic routing to their respective endpoints. This is accomplished by adding `Route`s which point to the `proddetail-v1` virtual nodes.
App Mesh also provides the VirtualService construct which allows you to specify a logical service path for application traffic. In this example, they send traffic to VirtualRouters, which then route traffic to the VirtualNodes.
Looking at the [meshed_app.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/meshed_app.yaml), below is the `proddetail` VirtualService and VirtualRouter which will route the traffic to version 1 of backend service `proddetail-v1`. 

{{< output >}}
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualService
metadata:
  name: proddetail
  namespace: prodcatalog-ns
spec:
  awsName: proddetail.prodcatalog-ns.svc.cluster.local
  provider:
    virtualRouter:
      virtualRouterRef:
        name: proddetail-router
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualRouter
metadata:
  name: proddetail-router
  namespace: prodcatalog-ns
spec:
  listeners:
    - portMapping:
        port: 3000
        protocol: http
  routes:
    - name: proddetail-route
      httpRoute:
        match:
          prefix: /
        action:
          weightedTargets:
            - virtualNodeRef:
                name: proddetail-v1
              weight: 100
---
{{< /output >}}

With the basic constructs understood, it's time to create the mesh and its resources.

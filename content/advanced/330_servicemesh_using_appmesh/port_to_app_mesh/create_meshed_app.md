---
title: "Create the Meshed Application"
date: 2020-01-27T08:30:11-07:00
weight: 50
---

#### Create Mesh Object

Configure namespace with App Mesh Labels and deploy Mesh Object

```bash
kubectl apply -f deployment/mesh.yaml  
```   
{{< output >}}
namespace/prodcatalog-ns configured 
mesh.appmesh.k8s.aws/prodcatalog-mesh created
{{< /output >}}

Confirm the Mesh object and Namespace are created

```bash
kubectl describe namespace prodcatalog-ns
```    
{{< output >}}
Name:         prodcatalog-ns
Labels:       appmesh.k8s.aws/sidecarInjectorWebhook=enabled
            gateway=ingress-gw
            mesh=prodcatalog-mesh
Annotations:  Status:  Active
{{< /output >}}

```bash
kubectl describe mesh prodcatalog-mesh
```     
{{< output >}}
Status:
Conditions:
    Last Transition Time:  2020-11-02T16:43:03Z
    Status:                True
    Type:                  MeshActive
{{< /output >}}

#### Create App Mesh Resources for the services

```bash
kubectl apply -f deployment/meshed_app.yaml
```
{{< output >}}
virtualnode.appmesh.k8s.aws/prodcatalog created 
virtualservice.appmesh.k8s.aws/prodcatalog created 
virtualservice.appmesh.k8s.aws/proddetail created 
virtualrouter.appmesh.k8s.aws/proddetail-router created 
virtualrouter.appmesh.k8s.aws/prodcatalog-router created 
virtualnode.appmesh.k8s.aws/proddetail-v1 created 
virtualnode.appmesh.k8s.aws/frontend-node created 
virtualservice.appmesh.k8s.aws/frontend-node created 
{{< /output >}}

Get all the Meshed resources for your application services, you should see below response.
```bash
kubectl get virtualnode,virtualservice,virtualrouter -n prodcatalog-ns
```
{{< output >}}
NAME                                        ARN                                                                                                     AGE
virtualnode.appmesh.k8s.aws/frontend-node   arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualNode/frontend-node_prodcatalog-ns   3m4s
virtualnode.appmesh.k8s.aws/prodcatalog     arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualNode/prodcatalog_prodcatalog-ns     35m
virtualnode.appmesh.k8s.aws/proddetail-v1   arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualNode/proddetail-v1_prodcatalog-ns   35m

NAME                                           ARN                                                                                                                          AGE
virtualservice.appmesh.k8s.aws/frontend-node   arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualService/frontend-node.prodcatalog-ns.svc.cluster.local   3m4s
virtualservice.appmesh.k8s.aws/prodcatalog     arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualService/prodcatalog.prodcatalog-ns.svc.cluster.local     35m
virtualservice.appmesh.k8s.aws/proddetail      arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualService/proddetail.prodcatalog-ns.svc.cluster.local      35m

NAME                                               ARN                                                                                                            AGE
virtualrouter.appmesh.k8s.aws/prodcatalog-router   arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualRouter/prodcatalog-router_prodcatalog-ns   35m
virtualrouter.appmesh.k8s.aws/proddetail-router    arn:aws:appmesh:us-west-2:$ACCOUNT_ID:mesh/prodcatalog-mesh/virtualRouter/proddetail-router_prodcatalog-ns    35m
{{< /output >}}

#### Go to Console and check the App Mesh Resources information
![App Mesh](/images/app_mesh_fargate/mesh_console.png)
![virtual nodes](/images/app_mesh_fargate/mesh-3.png)
![virtual services](/images/app_mesh_fargate/mesh-1.png)
![virtual routers](/images/app_mesh_fargate/mesh-2.png)

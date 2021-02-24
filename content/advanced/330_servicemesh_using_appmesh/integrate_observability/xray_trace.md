---
title: "XRay Trace"
date: 2020-01-27T08:30:11-07:00
weight: 93
draft: false
---

#### XRay Trace

AWS X-Ray helps developers and DevOps engineers quickly understand how an application and its underlying services are performing. When it’s integrated with AWS App Mesh, the combination makes for a powerful analytical tool.

To instrument your application code, use the [X-Ray SDK](https://docs.aws.amazon.com/xray/index.html). The SDK records data about incoming and outgoing requests and sends it to the X-Ray daemon, which relays the data in batches to X-Ray. 
See the examples in the code below for our Product Catalog demo application.

+ [Frontend](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/apps/frontend_node/server.js#L8)
+ [Product Catalog](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/apps/product_catalog/app.py#L23)
+ [Catalog Detail](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/apps/catalog_detail/app.js#L8)

##### Service Map

Log into console, navigate to X-Ray, you should see the below in the Service Map. AWS X-Ray service maps show information about call from the client to its downstream services.
The service graph arrows show the request workflow, which helps to understand the relationships between services. 
Below graph shows the traces when we access the Product Catalog application from the Load Balancer endpoint:

* First, the Envoy proxy `prodcatalog-mesh/ingress-gw` of VirtualGateway received the request and routed it to the Envoy proxy `prodcatalog-mesh/frontend-node`.
* Then, the Envoy proxy `prodcatalog-mesh/frontend-node` routed it to the server `Frontend Node`.
* Then, `Frontend Node` made a request to server `Product Catalog` to retrieve the products.
* Instead of directly calling the `Product Catalog` server, the request went to the frontend-node Envoy proxy and the proxy routed the call to `Product Catalog` server.
* Then, the Envoy proxy `prodcatalog-mesh/prodcatalog` received the request and routed it to the server `Product Catalog`.
* Then, `Product Catalog` made a request to server `Product Detail V1` to retrieve the catalog detail information for version 1.
* Instead of directly calling the `Product Detail V1` server, the request went to the prodcatalog Envoy proxy and the proxy routed the call to `Product Detail V1`.
* Then, the Envoy proxy `prodcatalog-mesh/prodetail-v1` received the request and routed it to the server `Product Detail V1`.
* Similar steps of workflow happens when `Product Detail V2` is accessed when we click on `Canary Deployment` button.

![\[Image NOT FOUND\]](/images/app_mesh_fargate/map.png)

##### Trace Details

**Frontend Node service to Product Catalog service**

Log into console, navigate to X-Ray -> Service Map -> Click on `prodcatalog-mesh/frontend-node_prodcatalog-ns`, you should see the below page.
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracef.png)

Now Click on `View Traces` in above page, you should see below which shows all the requests routed from `prodcatalog-mesh/frontend-node_prodcatalog-ns`
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracef-1.png)

Now Click on `http://prodcatalog.prodcatalog-ns.svc.cluster.local:5000/products/` and then click on any trace from the Trace List table to see the detailed traces for this request. 
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracef-2.png)
In this page, you see the number of request, latency for each hop in the trace between `prodcatalog-mesh/frontend-node_prodcatalog-ns` and the `Product Catalog` server. 
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracef-3.png)

**Product Catalog service to Product Detail V1 service**

Log into console, navigate to X-Ray -> Service Map -> Click on `prodcatalog-mesh/prodcatalog_prodcatalog-ns`, you should see the below page.
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracep-1.png)
Now Click on `View Traces` in above page, you should see below which shows all the requests routed from `prodcatalog-mesh/prodcatalog_prodcatalog-ns`
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracep-2.png)

Now Click on `http://prodetail.prodcatalog-ns.svc.cluster.local:5000/catalogDetail/` and then click on any trace from the Trace List table to see the detailed traces for this request. 
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracep-3.png)
In this page, you see the number of request, latency for each hop in the trace between `prodcatalog-mesh/prodcatalog_prodcatalog-ns` and the `Product Detail V1` server. 
![\[Image NOT FOUND\]](/images/app_mesh_fargate/tracep-4.png)


---
title: "Components"
date: 2018-11-13T16:37:17+09:00
weight: 10
draft: false
---

![App Mesh Architecture](/images/app_mesh/appmesh_overview.png)

App Mesh is made up of the following components:

* Service mesh: A service mesh is a logical boundary for network traffic between the services that reside within it. For more information, see [Service Meshes](https://docs.aws.amazon.com/app-mesh/latest/userguide/meshes.html).

* Virtual nodes: A virtual node acts as a logical pointer to a particular task group, such as an ECS service or a Kubernetes deployment. When you create a virtual node, you must specify the DNS service discovery name for your task group. For more information, see [Virtual Nodes](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_nodes.html).

* Envoy proxy and router manager: The Envoy proxy and its router manager container images configure your microservice task group to use the App Mesh service mesh traffic rules that you set up for your virtual routers and virtual nodes. You add these containers to your task group after you have created your virtual nodes, virtual routers, and routes. For more information, see [Envoy and Proxy Route Manager Images](https://docs.aws.amazon.com/app-mesh/latest/userguide/envoy.html).

* Virtual routers: The virtual router handles traffic for one or more service names within your mesh. For more information, see [Virtual Routers](https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_routers.html).

* Routes: A route is associated with a virtual router, and it directs traffic that matches a service name prefix to one or more virtual nodes. For more information, see [Routes](https://docs.aws.amazon.com/app-mesh/latest/userguide/routes.html).

In this chapter, we'll set up these components, and deploy a simple microservice to it, and then modify the App Mesh routes to demonstrate a canary deployment. 

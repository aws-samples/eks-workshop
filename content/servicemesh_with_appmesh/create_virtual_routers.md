---
title: "Create Virtual Routers and Routes"
date: 2018-11-13T16:37:17+09:00
weight: 40
draft: false
---
Virtual routers handle traffic for one or more service names within your mesh. After you create a virtual router, you can create and associate routes for your virtual router that direct incoming requests to different virtual nodes.

![Routers and Routes](/images/app_mesh/routers_and_routes.png)

Next, we'll create two Virtual Routers.

### Creating the routers

Each service name within the mesh must be fronted by a virtual router, and the service name you specify for the virtual router must be a real DNS service name within your VPC. In most cases you should just use the same service name that you specified for your virtual nodes.

The following JSON represents a virtual router called *colorgateway-vr*, for the service name *colorgateway.default.svc.cluster.local*.

Copy and paste the following into your terminal to create *colorgateway-vr*:

```
aws appmesh create-virtual-router  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "spec": {
        "serviceNames": [
            "colorgateway.default.svc.cluster.local"
        ]
    },
    "virtualRouterName": "colorgateway-vr"
}'
```

Similarly, for the virtual node *colorteller-vn*, copy and paste the following into your terminal to create *colorteller-vr*:

```
aws appmesh create-virtual-router  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "spec": {
        "serviceNames": [
            "colorteller.default.svc.cluster.local"
        ]
    },
    "virtualRouterName": "colorteller-vr"
}'
```

Next we'll add routes to these virtual routers.

### Creating the Routes

A route is associated with a virtual router, and it is used to match requests for a virtual router and distribute traffic accordingly to its associated virtual nodes.

You can use the prefix parameter in your route specification for path-based routing of requests. For example, if your virtual router service name is my-service.local, and you want the route to match requests to my-service.local/metrics, then your prefix should be /metrics.

If your route matches a request, you can distribute traffic to one or more target virtual nodes with relative weighting.

The following JSON represents a route called *colorgateway-route*, for the virtual router *colorgateway-vr*.

This route directs 100% of traffic to *colorgateway-vn* on requests matching the */* prefix.

Copy and paste the following into your terminal to create *colorgateway-route*:

```
aws appmesh create-route  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "routeName": "colorgateway-route",
    "spec": {
        "httpRoute": {
            "action": {
                "weightedTargets": [
                    {
                        "virtualNode": "colorgateway-vn",
                        "weight": 100
                    }
                ]
            },
            "match": {
                "prefix": "/"
            }
        }
    },
    "virtualRouterName": "colorgateway-vr"
}'
```

Similarly, for the virtual router *colorteller-vr*, copy and paste the following into your terminal to create *colorteller-route*:

```
aws appmesh create-route  --mesh-name APP_MESH_DEMO --cli-input-json '{
   "routeName": "colorteller-route",
   "spec": {
       "httpRoute": {
           "action": {
               "weightedTargets": [
                   {
                       "virtualNode": "colorteller-vn",
                       "weight": 1
                   }
               ]
           },
           "match": {
               "prefix": "/"
           }
       }
   },
   "virtualRouterName": "colorteller-vr"
}'
```

---
title: "Create Virtual Nodes"
date: 2018-11-13T16:37:17+09:00
weight: 30
draft: false
---

Next, we'll create five Virtual Nodes, one for each of the microservices in our application.

### More about Virtual Nodes

A virtual node acts as a logical pointer to a k8s service.

Service Discovery / DNS name of the virtual node is defined in the serviceDiscovery.dns attribute.

Inbound traffic parameters for the virtual node are specified in the listener attribute.

Outbound traffic the virtual node forwards to should be specified in the backend attribute.

### colorgateway-vn

We'll first define the virtual node colorgateway-vn.  colorgateway-vn will be the entrypoint to our app.

The following JSON defines:

* a virtual node named *colorgateway-vn*
* accessible via the hostname *colorgateway.default.svc.cluster.local*
* listening on port *9080*
* forwards to a k8s service (backend) named colorteller.default.svc.cluster.local

Copy and paste the following into your terminal to create the colorgateway virtual node:

```
aws appmesh create-virtual-node  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "spec": {
        "listeners": [
            {
                "portMapping": {
                    "port": 9080,
                    "protocol": "http"
                }
            }
        ],
        "serviceDiscovery": {
            "dns": {
                "serviceName": "colorgateway.default.svc.cluster.local"
            }
        },
        "backends": [
            "colorteller.default.svc.cluster.local"
        ]
    },
    "virtualNodeName": "colorgateway-vn"
}'
```

### colorteller-vn

collorteller-vn always *white* as its color response.

The following JSON defines:

* a virtual node named *colorteller-vn*
* accessible via the hostname *colorteller.default.svc.cluster.local*
* listening on port *9080*

Copy and paste the following into your terminal to create the *colorteller-vn* virtual node:

```
aws appmesh create-virtual-node  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "spec": {
        "listeners": [
            {
                "portMapping": {
                    "port": 9080,
                    "protocol": "http"
                }
            }
        ],
        "serviceDiscovery": {
            "dns": {
                "serviceName": "colorteller.default.svc.cluster.local"
            }
        }
    },
    "virtualNodeName": "colorteller-vn"
}'
```
Similarly, *colorteller-black-vn*, *colorteller-blue-vn*, and *colorteller-red-vn* return the colors black, blue, and red respectively.

Copy and paste these three virtual node definitions into your terminal to create the black, blue, and red collorteller virtual nodes:

### colorteller-black-vn

```
aws appmesh create-virtual-node  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "spec": {
        "listeners": [
            {
                "portMapping": {
                    "port": 9080,
                    "protocol": "http"
                }
            }
        ],
        "serviceDiscovery": {
            "dns": {
                "serviceName": "colorteller-black.default.svc.cluster.local"
            }
        }
    },
    "virtualNodeName": "colorteller-black-vn"
}'
```
### colorteller-blue-vn

```
aws appmesh create-virtual-node  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "spec": {
        "listeners": [
            {
                "portMapping": {
                    "port": 9080,
                    "protocol": "http"
                }
            }
        ],
        "serviceDiscovery": {
            "dns": {
                "serviceName": "colorteller-blue.default.svc.cluster.local"
            }
        }
    },
    "virtualNodeName": "colorteller-blue-vn"
}'
```

### colorteller-red-vn

```
aws appmesh create-virtual-node  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "spec": {
        "listeners": [
            {
                "portMapping": {
                    "port": 9080,
                    "protocol": "http"
                }
            }
        ],
        "serviceDiscovery": {
            "dns": {
                "serviceName": "colorteller-red.default.svc.cluster.local"
            }
        }
    },
    "virtualNodeName": "colorteller-red-vn"
}'
```

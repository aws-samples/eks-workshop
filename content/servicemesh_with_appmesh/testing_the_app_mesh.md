---
title: "Test the App on App Mesh"
date: 2018-11-13T16:37:17+09:00
weight: 50
draft: false
---

We now have both App Mesh and the application deployed.  Next comes the fun part of seeing how we can use App Mesh to change the charactertics of the application.

### Open Two Terminals

You should already have one terminal open.  Click the widget on the Cloud9 GUI and open a second terminal.

### Use curler to fetch the application response

In the first terminal, run the following command to connect to the curler pod with a bash shell (you may be prompted to hit enter to get a command line prompt):

```
kubectl run -it curler --image=tutum/curl /bin/bash
```

Next, with a shell open to the curler pod, paste the following to repeatedly request the colorgateway service:

```
while [ 1 ]; do  curl -s --connect-timeout 2 http://colorgateway.default.svc.cluster.local:9080/color;echo;sleep 1; done

```
Every second, you should see the response *white*.  

This is because colorgateway always forwards to colorteller, which via the colorteller-route, always routes to *colorteller-vn* (which will always respond with *white*).

Let's modify the colorteller-route so it instead routes to the blue, red, and black colorteller virtual nodes, each at a 30% weighted ratio.

### Modify colorteller-route

To modify *colorteller-route*, copy and paste the following into the *other* terminal (the one that is not making the curl requests):

```
aws appmesh update-route  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "routeName": "colorteller-route",
    "spec": {
        "httpRoute": {
            "action": {
                "weightedTargets": [
                    {
                            "virtualNode": "colorteller-blue-vn",
                            "weight": 3
                        },
                        {
                            "virtualNode": "colorteller-red-vn",
                            "weight": 3
                        },
                        {
                            "virtualNode": "colorteller-black-vn",
                            "weight": 3
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

If you look at the curler terminal, you should now see an equal distribution of traffic to the blue, red, and black virtual nodes.

For fun, to see a 50/50 weighted response of only the red and black virtual nodes, copy and paste the following route:

```
aws appmesh update-route  --mesh-name APP_MESH_DEMO --cli-input-json '{
    "routeName": "colorteller-route",
    "spec": {
        "httpRoute": {
            "action": {
                "weightedTargets": [
                        {
                            "virtualNode": "colorteller-red-vn",
                            "weight": 5
                        },
                        {
                            "virtualNode": "colorteller-black-vn",
                            "weight": 5
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

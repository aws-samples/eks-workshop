---
title: "Clean Up"
date: 2018-11-13T16:37:17+09:00
weight: 60
draft: false
---

There are three groups of components to remove when we're done:

1. App Mesh components
2. k8s Colorteller app
3. curler deployment

### Remove App Mesh components

To remove the App Mesh components, copy and paste this code into your terminal:

```
aws appmesh delete-route --mesh-name APP_MESH_DEMO --route-name colorteller-route --virtual-router-name colorteller-vr
aws appmesh delete-route --mesh-name APP_MESH_DEMO --route-name colorgateway-route --virtual-router-name colorgateway-vr
aws appmesh delete-virtual-router --mesh-name APP_MESH_DEMO --virtual-router-name colorteller-vr
aws appmesh delete-virtual-router --mesh-name APP_MESH_DEMO --virtual-router-name colorgateway-vr
aws appmesh delete-virtual-node --mesh-name APP_MESH_DEMO --virtual-node-name colorgateway-vn
aws appmesh delete-virtual-node --mesh-name APP_MESH_DEMO --virtual-node-name colorteller-vn
aws appmesh delete-virtual-node --mesh-name APP_MESH_DEMO --virtual-node-name colorteller-red-vn
aws appmesh delete-virtual-node --mesh-name APP_MESH_DEMO --virtual-node-name colorteller-black-vn
aws appmesh delete-virtual-node --mesh-name APP_MESH_DEMO --virtual-node-name colorteller-blue-vn
aws appmesh delete-mesh --mesh-name APP_MESH_DEMO
```

### Remove Colorteller App

To remove the Colorteller App, copy and paste this code into your terminal:

```
kubectl delete -f https://raw.githubusercontent.com/geremyCohen/colorapp/master/colorapp.yaml
```

### Remove Curler

To remove curler, copy and paste this code into your terminal:

```
kubectl delete deployment.apps/curler
```

---
title: "Create the k8s app"
date: 2018-11-13T16:37:17+09:00
weight: 50
draft: false
---

Up to this point, we've created all required components of the app mesh (virtual nodes, virtual routers, and routes) to support our application.   In this chapter, we'll actually deploy the k8s application.

### Deploying the k8s Colorteller App

To deploy app, copy and paste the following into your terminal:

```
kubectl apply -f https://raw.githubusercontent.com/geremyCohen/colorapp/master/colorapp.yaml

```

### Deploying Curler

In addition to deploying the application, we'll also deploy Curler, which is a simple image that provide curl functionality.  To deploy the curler pods, copy and paste the following:

```
kubectl run -it curler --image=tutum/curl /bin/bash

```

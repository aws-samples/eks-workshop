---
title: "Define the Injector Targets"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

By default, the injector won't act on any pods — we'll need to give it criteria on what its auto-inject targets should be.

For the purpose of this tutorial, we'll make it inject the App Mesh sidecar into any new pods created in the prod namespace.  To do that, we'll label our prod namespace with appmesh.k8s.aws/sidecarInjectorWebhook=enabled.

Return to the repo's base dir:

```
cd ..
```

And run the following command to label the prod namespace:

```
kubectl label namespace prod appmesh.k8s.aws/sidecarInjectorWebhook=enabled
```

Output should be similar to:

```
namespace/prod labeled
```
Next, we'll verify the Injector Controller is running:

```
kubectl get pods -nappmesh-inject
```
You should see output similar to:

```
NAME                                   READY   STATUS    RESTARTS   AGE
aws-app-mesh-inject-78c59cc699-9jrb4   1/1     Running   0          1h
```


With the injector portion of the setup complete, lets move on to creating the App Mesh components.

---
title: "Clean Up"
date: 2018-08-07T08:30:11-07:00
weight: 500
---

To remove all the objects that the Helm Chart created, we can use [Helm delete](https://docs.helm.sh/helm/#helm-delete).

Before we delete it though, we can verify what we have running via the [Helm list](https://docs.helm.sh/helm/#helm-list) command:

```
helm list
```

You should see output similar to below, which show that mywebserver is installed:

```
NAME            REVISION        UPDATED                         STATUS          CHART           APP VERSION     
mywebserver     1               Tue Nov 13 19:55:25 2018        DEPLOYED        nginx-1.1.2     1.14.1          
```

It was a lot of fun; we had some great times sending HTTP back and forth, but now its time to delete this deployment.  To delete:

```
helm delete --purge mywebserver
```

And you should be met with the output:

```
release "mywebserver" deleted
```

kubectl will also demonstrate that our pods and service are no longer available:

```
kubectl get pods -l app=mywebserver-nginx
kubectl get service mywebserver-nginx -o wide
```

As would trying to access the service via the web browser via a page reload.

With that, cleanup is complete.

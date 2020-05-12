---
title: "Canary Testing with a v2"
date: 2018-08-07T08:30:11-07:00
weight: 90
---

A canary release is a method of slowly exposing a new version of software. The theory behind it is that by serving the new version of the software initially to say, 5% of requests, if there is a problem, the problem only impacts a very small percentage of users before its discovered and rolled back.

So now back to our DJ App scenario...  `metal-v2` and `jazz-v2` services are out, and they now include the city each artist is from in the response.

Let's see how we can release these new versions in a canary fashion using `AWS App Mesh`.

When we're complete, requests to metal and jazz will be distributed in a weighted fashion to both the v1 and v2 versions.

![App Mesh](/images/app_mesh_ga/140-v2-mesh.png)

## jazz-v2

### Deploy jazz-v2

To begin, we'll rollout the v2:

* deployments
* services
* Virtual Nodes
 
 With a single YAML file:

```bash
kubectl -n prod apply -f 5_canary/jazz_v2.yaml
```

Output should be similar to:
{{< output >}}
deployment.apps/jazz-v2 created
service/jazz-v2 created
virtualnode.appmesh.k8s.aws/jazz-v2 created
{{< /output >}}

### Update the jazz Virtual Service

Next, we'll update the jazz Virtual Service by modifying the route to spread traffic **90/10** across the two versions.

If we take a look at it now, we'll see the current route which points to `jazz-v1` 100%:

```bash
kubectl -n prod describe virtualservice jazz | grep --color=always -e "^" -e "Weight:"
```

yields:
{{< output >}}
Name:         jazz.prod.svc.cluster.local
Namespace:    prod
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"appmesh.k8s.aws/v1beta1","kind":"VirtualService","metadata":{"annotations":{},"name":"jazz.prod.svc.cluster.local","namesp...
API Version:  appmesh.k8s.aws/v1beta1
Kind:         VirtualService
Metadata:
  Creation Timestamp:  2019-03-23T00:15:08Z
  Generation:          3
  Resource Version:    2851527
  Self Link:           /apis/appmesh.k8s.aws/v1beta1/namespaces/prod/virtualservices/jazz.prod.svc.cluster.local
  UID:                 b76eed59-4d00-11e9-87e6-06dd752b96a6
Spec:
  Mesh Name:  dj-app
  Routes:
    Http:
      Action:
        Weighted Targets:
          Virtual Node Name:  jazz-v1
          Weight:             100
      Match:
        Prefix:  /
    Name:        jazz-route
  Virtual Router:
    Name:  jazz-router
Status:
  Conditions:
Events:  <none>
{{< /output >}}

We apply the updated service definition:

```bash
kubectl -n prod apply -f 5_canary/jazz_service_update.yaml
```

And when we describe the Virtual Service again, we see the updated route:

```bash
kubectl -n prod describe virtualservice jazz | grep --color=always -e "^" -e "Weight:"
```

as 90/10:
{{< output >}}
Name:         jazz.prod.svc.cluster.local
Namespace:    prod
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"appmesh.k8s.aws/v1beta1","kind":"VirtualService","metadata":{"annotations":{},"name":"jazz.prod.svc.cluster.local","namesp...
API Version:  appmesh.k8s.aws/v1beta1
Kind:         VirtualService
Metadata:
  Creation Timestamp:  2019-03-23T00:15:08Z
  Generation:          4
  Resource Version:    2851774
  Self Link:           /apis/appmesh.k8s.aws/v1beta1/namespaces/prod/virtualservices/jazz.prod.svc.cluster.local
  UID:                 b76eed59-4d00-11e9-87e6-06dd752b96a6
Spec:
  Mesh Name:  dj-app
  Routes:
    Http:
      Action:
        Weighted Targets:
          Virtual Node Name:  jazz-v1
          Weight:             90
          Virtual Node Name:  jazz-v2
          Weight:             10
      Match:
        Prefix:  /
    Name:        jazz-route
  Virtual Router:
    Name:  jazz-router
Status:
  Conditions:
Events:  <none>
{{< /output >}}

## metal-v2

### Deploy metal-v2

We will perform the same steps to deploy `metal-v2`.

Rollout the v2:

* deployments
* services
* Virtual Nodes
  
With a single YAML file:

```bash
kubectl -n prod apply  -f 5_canary/metal_v2.yaml
```

Output should be similar to:
{{< output >}}
deployment.apps/metal-v2 created
service/metal-v2 created
virtualnode.appmesh.k8s.aws/metal-v2 created
{{< /output >}}

### Update the metal Virtual Service

If we take a look at it now, we'll see the current route which points to `metal-v1` 100%:

```bash
kubectl -n prod describe virtualservice metal | grep --color=always -e "^" -e "Weight:"
```


Update the metal Virtual Service by modifying the route to spread traffic **50/50** across the two versions:

```bash
kubectl -n prod apply -f 5_canary/metal_service_update.yaml
```

And when we describe the Virtual Service again, we see the updated route:

```bash
kubectl -n prod describe virtualservice metal | grep --color=always -e "^" -e "Weight:"
```

yields:
{{< output >}}
Name:         metal.prod.svc.cluster.local
Namespace:    prod
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"appmesh.k8s.aws/v1beta1","kind":"VirtualService","metadata":{"annotations":{},"name":"metal.prod.svc.cluster.local","names...
API Version:  appmesh.k8s.aws/v1beta1
Kind:         VirtualService
Metadata:
  Creation Timestamp:  2019-03-23T00:15:08Z
  Generation:          2
  Resource Version:    2852282
  Self Link:           /apis/appmesh.k8s.aws/v1beta1/namespaces/prod/virtualservices/metal.prod.svc.cluster.local
  UID:                 b784e824-4d00-11e9-87e6-06dd752b96a6
Spec:
  Mesh Name:  dj-app
  Routes:
    Http:
      Action:
        Weighted Targets:
          Virtual Node Name:  metal-v1
          Weight:             50
          Virtual Node Name:  metal-v2
          Weight:             50
      Match:
        Prefix:  /
    Name:        metal-route
  Virtual Router:
    Name:  metal-router
Status:
  Conditions:
Events:  <none>
{{< /output >}}

Now that the v2's are deployed, let's test them out.

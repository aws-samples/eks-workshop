---
title: "Testing Canary"
date: 2020-01-27T08:30:11-07:00
weight: 100
---

Get the Loadbalancer endpoint
```bash
export LB_NAME=$(kubectl get svc ingress-gw -n prodcatalog-ns -o jsonpath="{.status.loadBalancer.ingress[*].hostname}") 
echo $LB_NAME
```
Now, back in your browser, you should see below screen which shows that Catalog Detail `proddetail-v1` Version 1 is being used.

![frontend](/images/app_mesh_fargate/ui3.png)

Now click on the button **Canary Deployment** few times as we set the route weight as 10% to `proddetail` V2 and 90% to `proddetail` V1, 
you should see information coming from Product Catalog `proddetail-v2` V2 after few clicks. You can see the `XYZ.com` vendor in the detail for `proddetail` V2.

![canaey](/images/app_mesh_fargate/lbfrontend-2.png)

Once we gain confidence in our new service version 2, and we see no error or latency issue, then we can decide to divert more traffic gradually to version V2.
In below example we shift the traffic weight to 50% for both proddetail service versions in VirualRouter.

![canary](/images/app_mesh_fargate/canary50-1.png)

{{< output >}}
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualRouter
metadata:
  name: proddetail-router
  namespace: prodcatalog-ns
spec:
.....
  routes:
    - name: proddetail-route
      httpRoute:
        match:
          prefix: /
        action:
          weightedTargets:
            - virtualNodeRef:
                name: proddetail-v1
              weight: 50
            - virtualNodeRef:
                name: proddetail-v2
              weight: 50
---
{{< /output >}}

If anything were to go wrong, you can simply rollback to the known-good v1 version of the services by changing the weight in VirtualRouter to 100% to version 1. 
Once you've verified things are good with the new versions, you can shift all traffic to them and deprecate v1.

Congrats on rolling out your new feature! Now lets see the logs and traces of our Application Services to get the end to end visibility in terms of observability.

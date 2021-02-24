---
title: "Canary Release"
date: 2020-01-27T08:30:11-07:00
weight: 50
draft: false
---

A canary release is a method of slowly exposing a new version of software. The theory behind it is that by serving the new version of the software initially to say, 5% of requests, if there is a problem, the problem only impacts a very small percentage of users before its discovered and rolled back.

So now back to our Product Catalog App scenario, `proddetail-v2` service is released, and they now include more product catalog vendors e.g "XYZ.com" (see below).
{{< output >}}
{   "version":"2",
    "names":["ABC.com","XYZ.com"]
}
{{< /output >}}

Let's see how we can release this new version of `proddetail-v2` in a canary fashion using `AWS App Mesh`. When we're done, our app will look more like the following:
                                                                                                           
![Product Catalog App with App Mesh](/images/app_mesh_fargate/architecture-1.png)
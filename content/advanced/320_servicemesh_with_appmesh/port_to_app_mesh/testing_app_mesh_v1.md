---
title: "Testing the App Mesh"
date: 2018-08-07T08:30:11-07:00
weight: 80
---

We should now be able to call `metal` or `jazz` from `dj`, and be routed to either `metal-v1` or `jazz-v1`.

![App Mesh](/images/app_mesh_ga/135-v1-mesh.png)

To test if our ported DJ App is working as expected, we'll first exec into the dj container.

```bash
export DJ_POD_NAME=$(kubectl get pods -n prod -l app=dj -o jsonpath='{.items[].metadata.name}')

kubectl -n prod exec -it ${DJ_POD_NAME} -c dj bash
```

 Output should be similar to:

{{< output >}}
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
{{< /output >}}

Now that we have a root prompt into the DJ pod, we'll make a curl request to the virtual service jazz on port 9080, simulating what would happen if code running in the same pod made a request to the jazz backend:

```bash
curl -s jazz.prod.svc.cluster.local:9080 | json_pp
```

Output should be similar to:
{{< output >}}
[
   "Astrud Gilberto",
   "Miles Davis"
]
{{< /output >}}

Try it again, but issue the command to the virtual metal service:

```bash
curl -s metal.prod.svc.cluster.local:9080 | json_pp
```

You should get a list of heavy metal bands back:
{{< output >}}
[
   "Megadeth",
   "Judas Priest"
]
{{< /output >}}

When you're done exploring this vast, service-mesh-enabled world of music, hit **CTRL-D**, or type exit to exit the container's shell

Congrats! You've migrated the initial architecture to provide the same functionality, but now with `AWS App Mesh` Virtual Services.  

Let's see the true power of `AWS APP Mesh` service mesh-based architecture by adding a new version of the metal and jazz services, and taking a closer look at how we can route between the different versions, which is very useful when implementing canary testing.

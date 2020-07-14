---
title: "Testing the Application"
date: 2018-08-07T08:30:11-07:00
weight: 80
---

Now it's time to test. Calls can be made to `metal` or `jazz` from within the `dj` pod and they are routed to either the `metal-v1` or `jazz-v1` endpoints, respectively.

![App Mesh](/images/app_mesh_ga/135-v1-mesh.png)

To test if our ported DJ App is working as expected, we'll first exec into the `dj` container.

```bash
export DJ_POD_NAME=$(kubectl get pods -n prod -l app=dj -o jsonpath='{.items[].metadata.name}')

kubectl -n prod exec -it ${DJ_POD_NAME} -c dj bash
```

You will see a prompt from within the `dj` container.

{{< output >}}
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
{{< /output >}}

Test the confiuration by issuing a curl request to the virtual service `jazz` on port 9080, simulating what would happen if code running in the same pod made a request to the jazz backend:

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

Now test the `metal` service:

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

When you're done exploring this vast, now mesh-enabled world of music, hit **CTRL-D**, or type exit to exit the container's shell

Congrats! You've migrated the initial architecture to provide the same functionality, but now with the wide array of `AWS App Mesh` features at your disposal.

Let's try out one of those features by adding a new version of the `metal` and `jazz` backend services, and adding some new configuration to our virtual routers to shift traffic between the different versions.

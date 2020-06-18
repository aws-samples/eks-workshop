---
title: "Testing DJ App v2"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

To test if our canary is working as expected, once again exec into the `dj` container and send some requests.

```bash
export DJ_POD_NAME=$(kubectl get pods -n prod -l app=dj -o jsonpath='{.items[].metadata.name}')

kubectl -n prod exec -it ${DJ_POD_NAME} -c dj bash
```

Once at the container's prompt, issue a series of curl's to test the traffic distribution.

{{< output >}}
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
{{< /output >}}

```bash
while true; do
  curl http://jazz.prod.svc.cluster.local:9080/
  echo
  sleep .5
done
```

Output should be similar to this, with about 5% of our traffic getting the new version.

{{< output >}}
...
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto (Bahia, Brazil)","Miles Davis (Alton, Illinois)"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
...
{{< /output >}}

Hit *CTRL-C* to stop the looping.

At this point, You would typically monitor metrics from the new version of the service, and slowly roll out more traffic to it.

Let's live dangerously and shift 50% of our traffic to v2. Use your favorite editor and modify the `VirtualRouter` configurations for both `jazz-router` and `metal-router`, then apply your changes and re-test.

Hint: look for the `weight` values specified in the `weightedTargets` specification.

Once you've modified the router configurations in YAML, apply your changes.

```bash
kubectl apply -f 3_canary_new_version/v2_app.yaml
```

{{< output >}}
virtualrouter.appmesh.k8s.aws/jazz-router configured
virtualrouter.appmesh.k8s.aws/metal-router configured
virtualnode.appmesh.k8s.aws/jazz-v2 unchanged
virtualnode.appmesh.k8s.aws/metal-v2 unchanged
deployment.apps/jazz-v2 unchanged
deployment.apps/metal-v2 unchanged
service/jazz-v2 unchanged
service/metal-v2 unchanged
{{< /output >}}

Now jump back into the `dj` container and send some requests.

```bash
kubectl -n prod exec -it ${DJ_POD_NAME} -c dj bash
```

{{< output >}}
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
{{< /output >}}

```bash
while true; do
  curl http://metal.prod.svc.cluster.local:9080/
  echo
  sleep .5
done
```

You should output similar to this, with about 50% of your traffic routing to the new version.

{{< output >}}
["Megadeth","Judas Priest"]
["Megadeth","Judas Priest"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
["Megadeth","Judas Priest"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
["Megadeth","Judas Priest"]
["Megadeth","Judas Priest"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
{{< /output >}}

If anything were to go wrong, you can simply rollback to the known-good v1 version of the services. Once you've verified things are good with the new versions, you can shift all traffic to them and deprecate v1.

Congrats on rolling out your new feature!

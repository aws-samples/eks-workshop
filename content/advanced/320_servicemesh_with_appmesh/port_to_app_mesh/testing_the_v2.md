---
title: "Testing DJ App v2"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

## Connect to the  `dj` container

To test if its working as expected, we'll exec into the `dj` container inside the `dj`pod.

```bash
export DJ_POD_NAME=$(kubectl get pods -n prod -l app=dj -o jsonpath='{.items[].metadata.name}')

kubectl -n prod exec -it ${DJ_POD_NAME} -c dj bash
```

 Output should be similar to:
{{< output >}}
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
{{< /output >}}

## Test canary between metal-v1 and metal-v2

We'll issue our curl request to the metal virtual service:

```bash
while true; do
  curl http://metal.prod.svc.cluster.local:9080/
  echo
  sleep .5
done
```

Output should loop about **50/50** between the v1 and v2 versions of the metal service, similar to:
{{< output >}}
...
["Megadeth","Judas Priest"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
["Megadeth","Judas Priest"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
...
{{< /output >}}

Hit *CTRL-C* to stop the looping.

## Test canary between jazz-v1 and jazz-v2

We'll next perform a similar test, but against the `jazz` virtual service.

```bash
while true; do
  curl http://jazz.prod.svc.cluster.local:9080/
  echo
  sleep .5
done
```

Output should loop about in a **90/10** ratio between the v1 and v2 versions of the jazz service, similar to:
{{< output >}}
...
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto (Bahia, Brazil)","Miles Davis (Alton, Illinois)"]
["Astrud Gilberto","Miles Davis"]
...
{{< /output >}}

Hit *CTRL-C* to stop the looping, and type exit to quit the container's shell.

Congrats on implementing the DJ App onto App Mesh!

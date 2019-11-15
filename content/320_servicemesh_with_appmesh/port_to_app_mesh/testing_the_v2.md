---
title: "Testing DJ App v2"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

To test if its working as expected, we'll exec into the DJ pod.  To do that, we get the name of our dj pod by listing all pods with the dj selector:

```
kubectl get pods -nprod -l app=dj
```

 Output should be similar to:

```
NAME                  READY     STATUS    RESTARTS   AGE
dj-5b445fbdf4-8xkwp   1/1       Running   0          32s
```

Next, we'll exec into the DJ pod, and make a curl request to the virtual service jazz, simulating what would happen if code running in the same pod made a request to the metal service by entering the following:

```
kubectl exec -nprod -it <your-dj-pod-name> -c dj bash
```

 Output should be similar to:

```
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
```

Now that we have a root prompt into the DJ pod, we'll issue our curl request to the jazz virtual service:

```
while [ 1 ]; do curl http://metal.prod.svc.cluster.local:9080/;echo; done
```

Output should loop about 50/50 between the v1 and v2 versions of the metal service, similar to:
```
...
["Megadeth","Judas Priest"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
["Megadeth","Judas Priest"]
["Megadeth (Los Angeles, California)","Judas Priest (West Bromwich, England)"]
...
```

Hit CTRL-C to stop the looping.

We'll next perform a similar test, but against the jazz service.  Issue a curl request to the jazz virtual service from within the dj pod:

```
while [ 1 ]; do curl http://jazz.prod.svc.cluster.local:9080/;echo; done
```

Output should loop about in a 90/10 ratio between the v1 and v2 versions of the jazz service, similar to:

```
...
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto","Miles Davis"]
["Astrud Gilberto (Bahia, Brazil)","Miles Davis (Alton, Illinois)"]
["Astrud Gilberto","Miles Davis"]
...
```

Hit CTRL-C to stop the looping, and type exit to exit the pod's shell.

Congrats on implementing the DJ App onto App Mesh!

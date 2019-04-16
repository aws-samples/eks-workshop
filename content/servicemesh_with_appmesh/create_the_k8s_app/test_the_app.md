---
title: "Test DJ App"
date: 2018-08-07T08:30:11-07:00
weight: 70
---

To test what we've just created, we'll exec into the DJ pod, and curl out to the jazz-v1 and metal-v1 backends.

First, we get the name of our DJ pod by listing all pods with the dj app selector:

```
kubectl get pods -nprod -l app=dj
```

 Output should be similar to:

```
NAME                  READY     STATUS    RESTARTS   AGE
dj-5b445fbdf4-8xkwp   1/1       Running   0          32s
```

Next, we'll exec into the DJ pod:

```
kubectl exec -nprod -it <your-dj-pod-name> bash
```

 Output should be similar to:

```
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
```

Now that we have a root prompt into the DJ pod, we'll issue a curl request to the jazz-v1 backend service:

```
curl jazz-v1.prod.svc.cluster.local:9080;echo
```

Output should be similar to:

```
["Astrud Gilberto","Miles Davis"]

```

Try it again, but issue the command to the metal-v1.prod.svc.cluster.local backend on port 9080:

```
curl metal-v1.prod.svc.cluster.local:9080;echo
```

 You should get a list of heavy metal bands back:

```
["Megadeth","Judas Priest"]
```

When you're done exploring this vast world of music, hit CTRL-D, or type exit to exit the container's shell:

```
root@dj-779566bbf6-cqpxt:/usr/src/app# exit
command terminated with exit code 1
$
```

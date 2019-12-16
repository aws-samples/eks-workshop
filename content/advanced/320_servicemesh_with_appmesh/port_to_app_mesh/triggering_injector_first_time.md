---
title: "Bootstrap the Injector"
date: 2018-08-07T08:30:11-07:00
weight: 70
---

Right now, if we describe any of the pods running in the prod namespace, we'll notice that they are running with just one container, the same one we initially deployed it with:

```
kubectl get pods -nprod
```

yields:
{{< output >}}
NAME                        READY   STATUS    RESTARTS   AGE
dj-5b445fbdf4-qf8sv         1/1     Running   0          3h
jazz-v1-644856f4b4-mshnr    1/1     Running   0          3h
metal-v1-84bffcc887-97qzw   1/1     Running   0          3h
{{< /output >}}

and to take a closer look:

```
kubectl describe pods/dj-5b445fbdf4-qf8sv -nprod
```

yields:
{{< output >}}
...
Containers:
  dj:
    Container ID:   docker://76e6d5f7101dfce60158a63cf7af9fcb3c821c087db360e87c5e2fb8850b7aa9
    Image:          970805265562.dkr.ecr.us-west-2.amazonaws.com/hello-world:latest
    Image ID:       docker-pullable://970805265562.dkr.ecr.us-west-2.amazonaws.com/hello-world@sha256:581fe44cf2413a48f0cdf005b86b025501eaff6cafc7b26367860e07be060753
    Port:           9080/TCP
    Host Port:      0/TCP
    State:          Running
...
{{< /output >}}

The injector controller we installed earlier watches for new pods to be created, and ensures any new pods that are created in the prod namespace are injected with the App Mesh sidecar.  Since our dj pods were already running before the injector was created, we'll force them to be recreated, this time with the sidecars auto-injected into them.

In production, there are more graceful ways to do this, but for the purpose of this tutorial, an easy way to have the deployment recreate the pods in an innocuous fashion is to patch into the deployment a simple date annotation.

To do that with our current deployment, first we get all the prod namespace pod names:

```
kubectl get pods -nprod
```

The output will be the pod names:
{{< output >}}
NAME                        READY   STATUS    RESTARTS   AGE
dj-5b445fbdf4-qf8sv         1/1     Running   0          3h
jazz-v1-644856f4b4-mshnr    1/1     Running   0          3h
metal-v1-84bffcc887-97qzw   1/1     Running   0          3h
{{< /output >}}

Note that under the READY column, we see 1/1, which indicates one container is running for each pod.  

Next, run the following commands  to add a date label to each dj, jazz-v1, and metal-1 deployment, forcing the pods to be recreated:

```
kubectl patch deployment dj -nprod -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
kubectl patch deployment metal-v1 -nprod -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
kubectl patch deployment jazz-v1 -nprod -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
```

Once again, get the pods:
```
kubectl get pods -nprod
```

Now note how we see 2/2 under READY, which indicates two container for each pod are running:
{{< output >}}
NAME                        READY   STATUS    RESTARTS   AGE
dj-6cfb85cdd9-z5hsp         2/2     Running   0          10m
jazz-v1-79d67b4fd6-hdrj9    2/2     Running   0          16s
metal-v1-769b58d9dc-7q92q   2/2     Running   0          18s
{{< /output >}}

{{% notice note %}}
If you don't see the above exact output, and instead see “Terminating” or "Initializing" pods, wait about 10 seconds — (your redeployment is underway), and re-run the command. Run `kubectl get pods -nprod --watch` to see the entire process of initializaing and terminating pods.
{{% /notice %}}

```
kubectl get pods -nprod --watch
```
{{< output >}}
NAME                       READY   STATUS        RESTARTS   AGE
dj-76c74fd9b6-mlmnv        2/2     Running       0          39s
dj-8d4fc6ccd-vcknl         0/1     Terminating   0          19m
jazz-v1-76dcdf6695-wn27s   2/2     Running       0          37s
jazz-v1-f94cdc64d-mvd4l    0/1     Terminating   0          19m
metal-v1-699bcc5d9-mzc9x   2/2     Running       0          38s
dj-8d4fc6ccd-vcknl   0/1   Terminating   0     20m
dj-8d4fc6ccd-vcknl   0/1   Terminating   0     20m
jazz-v1-f94cdc64d-mvd4l   0/1   Terminating   0     20m
jazz-v1-f94cdc64d-mvd4l   0/1   Terminating   0     20m
{{< /output >}}

If we now describe the new dj pod to get more detail: 
```
kubectl describe pods/$(kubectl get pods -nprod | grep 'dj-' | awk '{print $1}') -nprod`
```
{{< output >}}
...
Containers:
  dj:
    Container ID:   docker://bef63f2e45fb911f78230ef86c2a047a56c9acf554c2272bc094300c6394c7fb
    Image:          970805265562.dkr.ecr.us-west-2.amazonaws.com/hello-world:latest
    ...
  envoy:
    Container ID:   docker://2bd0dc0707f80d436338fce399637dcbcf937eaf95fed90683eaaf5187fee43a
    Image:          111345817488.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.8.0.2-beta
    ...
{{< /output >}}

We'll see that both the original container, and the auto-injected sidecar will both be running for any new pods created in the prod namespace.

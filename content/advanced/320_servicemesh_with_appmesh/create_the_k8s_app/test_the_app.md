---
title: "Test DJ App"
date: 2018-08-07T08:30:11-07:00
weight: 70
---

To test what we've just created, we'll exec into the DJ pod, and curl out to the `jazz-v1` and `metal-v1` backends.

First, we get the name of our DJ pod by listing all pods with the dj app selector:

```bash
kubectl get pods -n prod -l app=dj
```

 Output should be similar to:

{{< output >}}
NAME                 READY   STATUS    RESTARTS   AGE
dj-8d4fc6ccd-ntjnq   1/1     Running   0          5m13s
{{< /output >}}

Next, we'll exec into the DJ pod:

```bash
export DJ_POD_NAME=$(kubectl get pods -n prod -l app=dj -o jsonpath='{.items[].metadata.name}')

kubectl exec -nprod -it ${DJ_POD_NAME} bash
```

 Output should be similar to:

{{< output >}}
root@dj-5b445fbdf4-8xkwp:/usr/src/app#
{{< /output >}}

Now that we have a root prompt into the DJ pod, we'll issue a curl request to the `jazz-v1` backend service:

```bash
curl -s jazz-v1:9080 | json_pp
```

Output should be similar to:
{{< output >}}
[
   "Astrud Gilberto",
   "Miles Davis"
]
{{< /output >}}

Try it again, but issue the command to the `metal-v1` backend:

```bash
curl -s metal-v1:9080 | json_pp
```

You should get a list of heavy metal bands back:

{{< output >}}
[
   "Megadeth",
   "Judas Priest"
]
{{< /output >}}

When you're done exploring this vast world of music, hit **CTRL-D**, or type exit to quit the container's shell

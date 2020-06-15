---
title: "Initializing Network Policy"
weight: 200
---

Now that we've seen that all the traffic is being allowed in the cluster, let's start tightening the policies, and restrict some of the traffic.  To do that, we will first create a _default deny_ policy that will block all inbound traffic in our default namespace unless it is specifically allowed.  To do that, we create a null policy that matches everything in the default namespace.

The YAML fragment that defines such a policy can be seen below

{{< output >}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
spec:
  podSelector:
    matchLabels: {}
{{< /output >}}

Now create a file called _default-deny.yaml_ with the above contents and install it in your cluster using kubectl.

```
$ kubectl apply -f default-deny.yaml
```

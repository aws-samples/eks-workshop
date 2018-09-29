---
title: "Initializing Network Policy"
weight: 200
---

Now that we've seen that all the traffic is being allowed in the cluster, let's start tightening the policies, and restrict some of the traffic.  To do that, we will first create a _default deny_ policy that will block all inbound traffic in our default namespace unless it is specifically allowed.  To do that, we create a null policy that matches everything in the default namespace.

The YAML that defines such a policy can be seen below:

```
cat <<EoF > ~/environment/default-deny.yaml
kind: NetworkPolicy
apiVersion: projectcalico.org/v3
metadata:
  name: default-deny
spec:
  selector:
EoF
```

We can apply the file called _default-deny.yaml_ with the above contents to your cluster using kubectl:

```
$ kubectl apply -f ~/environment/default-deny.yaml
```

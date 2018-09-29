---
title: "Policy Enabling the Backends"
weight: 210
---

Now, let's create a policy that allows the _ecsdemo-frontend_ microservice to
communicate with the _ecsdemo-nodejs_ microservice: 

```
cat <<EoF > ~/environment/ecsdemo-nodejs-policy.yaml
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: ecsdemo-nodejs
spec:
  selector: app == 'ecsdemo-nodejs'
  types:
  - Ingress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: app == 'ecsdemo-frontend'
    destination:
      ports:
      - 3000
EoF
```

We can load it into Kubernetes using kubectl:

```
$ kubectl apply -f ~/environment/ecsdemo-nodejs-policy.yaml
```

Once you've done that, again, look at the flow logs and you will see that traffic between the frontend and the nodejs services is now being allowed, but the traffic from the frontend to the crystal microservice is still being blocked.  Let's fix that.

```
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: ecsdemo-crystal
spec:
  selector: app == 'ecsdemo-crystal'
  types:
  - Ingress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: app == 'ecsdemo-frontend'
    destination:
      ports:
      - 3000
```

Use the same file create and kubectl apply steps that we used above to apply this new policy, and now you will see that all the frontend to backend traffic is now being allowed, again.

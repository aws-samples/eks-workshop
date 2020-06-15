---
title: "Find the Service Address"
date: 2018-09-18T17:40:09-05:00
weight: 40
---

Now that we have a running service that is `type: LoadBalancer` we need to find
the ELB's address.  We can do this by using the `get services` operation of kubectl:

```
kubectl get service ecsdemo-frontend
```

Notice the field isn't wide enough to show the FQDN of the ELB. We can adjust the
output format with this command:
```
kubectl get service ecsdemo-frontend -o wide
```

If we wanted to use the data programatically, we can also output via json. This is
an example of how we might be able to make use of json output:
```
ELB=$(kubectl get service ecsdemo-frontend -o json | jq -r '.status.loadBalancer.ingress[].hostname')

curl -m3 -v $ELB
```
{{% notice tip %}}
It will take several minutes for the ELB to become healthy and start passing traffic to the frontend pods.
{{% /notice %}}

You should also be able to copy/paste the loadBalancer hostname into your browser and see the application running.
Keep this tab open while we scale the services up on the next page.

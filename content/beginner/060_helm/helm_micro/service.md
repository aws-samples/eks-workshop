---
title: "Test the Service"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

To test the service our eksdemo Chart created, we'll need to get the name of the ELB endpoint that was generated when we deployed the Chart:

```sh
kubectl get svc ecsdemo-frontend -o jsonpath="{.status.loadBalancer.ingress[*].hostname}"; echo
```

Copy that address, and paste it into a new tab in your browser.  You should see something similar to:

![Example Service](/images/helm_micro/micro_example.png)

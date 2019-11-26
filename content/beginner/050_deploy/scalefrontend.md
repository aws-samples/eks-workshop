---
title: "Scale the Frontend"
date: 2018-09-18T17:40:09-05:00
weight: 60
---

#### Challenge:
**Let's also scale our frontend service!**

{{%expand "Expand here to see the solution" %}}
```
kubectl get deployments
kubectl scale deployment ecsdemo-frontend --replicas=3
kubectl get deployments
```
{{% /expand %}}

Check the browser tab where we can see our application running. You should
now see traffic flowing to multiple frontend services.

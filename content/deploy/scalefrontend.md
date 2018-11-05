---
title: "Scale the Frontend"
date: 2018-09-18T17:40:09-05:00
weight: 60
---

Let's also scale our frontend service the same way:
```
kubectl get deployments
kubectl scale deployment ecsdemo-frontend --replicas=3
kubectl get deployments
```

Check that all frontend pods are running on Spot Instances
```
 for n in $(kubectl get nodes -l lifecycle=Ec2Spot --no-headers | cut -d " " -f1); do kubectl get pods --namespace=default --no-headers --field-selector spec.nodeName=${n} ; done
```

Check the browser tab where we can see our application running. You should
now see traffic flowing to multiple frontend services.

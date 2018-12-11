---
title: "Redeploy Frontend Service"
date: 2018-09-18T17:40:09-05:00
weight: 40
---
Let’s redeploy the Frontend on Spot instance!

First let's take a look at all pods deployed on Spot instances

```bash
 for n in $(kubectl get nodes -l lifecycle=Ec2Spot --no-headers | cut -d " " -f1); do kubectl get pods --all-namespaces  --no-headers --field-selector spec.nodeName=${n} ; done
```

Now we will redeploy our edited Frontend Manifest

```bash
cd ~/environment/ecsdemo-frontend
kubectl apply -f kubernetes/deployment.yaml
```

We can again check all pods deployed on Spot Instances and should now see the frontend pods running on Spot instances

```bash
 for n in $(kubectl get nodes -l lifecycle=Ec2Spot --no-headers | cut -d " " -f1); do kubectl get pods --all-namespaces  --no-headers --field-selector spec.nodeName=${n} ; done
```

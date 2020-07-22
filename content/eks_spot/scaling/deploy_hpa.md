---
title: "Configure Horizontal Pod Autoscaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

So far we have scaled the number of replicas manually. We also have built an understanding around how Cluster Autoscaler does scale the cluster.
In this section we will deploy the **[Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)** and a rule to scale our application once it reaches a CPU threshold. The Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment or replica set based on observed CPU utilization or memory. 

{{% notice note %}}
Horizontal Pod Autoscaler is more versatile than just scaling on CPU and Memory. There are other projects different from the metric server that can be consider when looking scaling on the back of other metrics. For example [prometheus-adapter](https://github.com/helm/charts/tree/master/stable/prometheus-adapter) can be used wit custom metrics imported from [prometheus](https://prometheus.io/)
{{% /notice %}}


### Create an HPA resource associated with the Monte Carlo Pi Service

We will set up a rule to scales up when CPU exceeds 50% of the allocated container resource.

```
kubectl autoscale deployment monte-carlo-pi-service --cpu-percent=50 --min=3 --max=100
```

View the HPA using kubectl. You probably will see `<unknown>/50%` for 1-2 minutes and then you should be able to see `0%/50%`
```
kubectl get hpa
```




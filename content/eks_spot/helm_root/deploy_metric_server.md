---
title: "Deploy the Metric server"
date: 2020-03-07T08:30:11-07:00
weight: 20
---

### Deploy the Metrics Server
Metrics Server is a cluster-wide aggregator of resource usage data. These metrics will drive the scaling behavior of the [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). We will deploy the metrics server using `Helm` configured earlier in this workshop.

```
kubectl create namespace metrics
helm install metrics-server \
    stable/metrics-server \
    --version 2.10.0 \
    --namespace metrics
```

### Confirm the Metrics API is available.

Return to the terminal in the Cloud9 Environment
```
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```

{{% notice note %}}
It may take a minute or so for the metric service to fully initialize. If on your first attempt you don't get the output indicated below, wait for a minute or so and try again.
{{% /notice %}}


If all is well, you should see a status message similar to the one below in the response
```
status:
  conditions:
  - lastTransitionTime: 2018-10-15T15:13:13Z
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available
```

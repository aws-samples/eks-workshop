---
title: "Configure Horizontal Pod AutoScaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

## Deploy the Metrics Server

Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

These metrics will drive the scaling behavior of the [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

We will deploy the metrics server using [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server).

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
```

Lets' verify the status of the metrics-server `APIService` (it could take a few minutes).

```sh
kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'
```

{{< output >}}
{
  "conditions": [
    {
      "lastTransitionTime": "2020-11-10T06:39:13Z",
      "message": "all checks passed",
      "reason": "Passed",
      "status": "True",
      "type": "Available"
    }
  ]
}
{{< /output >}}

**We are now ready to scale a deployed application**

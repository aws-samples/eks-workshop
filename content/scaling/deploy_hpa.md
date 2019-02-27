---
title: "Configure Horizontal Pod AutoScaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

### Deploy the Metrics Server
Metrics Server is a cluster-wide aggregator of resource usage data. These metrics will drive the scaling behavior of the [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). We will deploy the metrics server using `Helm` configured in a previous [module](/helm_root/helm_intro/install/index.html)

```
helm install stable/metrics-server \
    --name metrics-server \
    --version 2.0.4 \
    --namespace metrics
```
### Confirm the Metrics API is available.

Return to the terminal in the Cloud9 Environment
```
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```
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

#### We are now ready to scale a deployed application

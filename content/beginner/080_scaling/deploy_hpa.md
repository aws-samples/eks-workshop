---
title: "Configure Horizontal Pod AutoScaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

## Deploy the Metrics Server

Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

These metrics will drive the scaling behavior of the [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

We will deploy the metrics server using `Helm` configured in a previous [module](/beginner/060_helm/helm_intro/install/index.html)

```sh
# create the metrics-service namespace
kubectl create namespace metrics

# deploy the metrics-server
helm install metrics-server \
    stable/metrics-server \
    --version 2.11.1 \
    --namespace metrics
```

{{% notice warning %}}
**Edit 2020-04-22**: some versions of EKS may get the following error once you [create the HPA in the next step](https://eksworkshop.com/scaling/test_hpa/)
{{% /notice %}}

```bash
kubectl describe hpa
```

{{< output >}}
... failed to get cpu utilization: unable to get metrics for resource cpu
{{< /output >}}

To fix, set the following values for the metric-server helm release [as described here](https://dev.to/setevoy/kubernetes-running-metrics-server-in-aws-eks-for-a-kubernetes-pod-autoscaler-4m9)

```bash
args:
  - --kubelet-preferred-address-types=InternalIP
```

Lets' verify the status of the metrics-server `APIService` (it could take several minutes)

```bash
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml | yq - r 'status'
```

{{< output >}}
status:
  conditions:
  - lastTransitionTime: "2020-02-18T21:33:26Z"
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available
{{< /output >}}

**We are now ready to scale a deployed application**

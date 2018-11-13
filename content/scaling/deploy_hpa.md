---
title: "Configure Horizontal Pod AutoScaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

### Deploy the Metrics Server

Metrics Server is a cluster-wide aggregator of resource usage data. These metrics will drive the scaling behavior of the [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). We will deploy the metrics server using `Helm` configured in a previous [module](../../helm)

```sh
helm install stable/metrics-server \
    --name metrics-server \
    --version 2.0.2 \
    --namespace metrics
```

### Confirm the Metrics API is available

Return to the terminal in the Cloud9 Environment

```sh
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```

If all is well, you should see a status message similar to the one below in the response

```text
status:
  conditions:
  - lastTransitionTime: 2018-10-15T15:13:13Z
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available
```

### Troubleshooting: Configure Access to the Metrics API

If the Metrics API server is not available and you see the status message bellow, you might need to configure additional ingress rule for nodes security group.

```text
status:
  conditions:
  - lastTransitionTime: 2018-04-17T12:34:34Z
    message: 'no response from https://10.100.11.77:443: Get https://10.100.11.77:443:
      net/http: request canceled while waiting for connection (Client.Timeout exceeded
      while awaiting headers)'
    reason: FailedDiscoveryCheck
    status: "False"
    type: Available
```

By default, Amazon EKS nodes security group does not allow incoming `https` connection from masters security group and the control plane cannot access the Metrics API.

Update the Amazon EKS Kubernetes nodes security groups to allow ingress / incoming `https` connections from the EKS masters security group.

![Configure Nodes SG](/images/hpa-eks-sg.png)

#### We are now ready to scale a deployed application

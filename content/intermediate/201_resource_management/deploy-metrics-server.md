---
title: "Deploy the Metrics Server"
date: 2021-11-10T00:00:00-03:00
weight: 9
draft: false
---
### Deploy the Metrics Server
Before starting to learn about Kubernetes resource management, you'll need to deploy the Metrics Server. Follow the instructions in the module [Deploy the Metrics Server](/beginner/080_scaling/deploy_hpa/#deploy-the-metrics-server) to enable the Kubernetes Metrics Server.

Verify that the metrics-server deployment is running the desired number of pods with the following command:
```sh
kubectl get deployment metrics-server -n kube-system
```
Output:
{{< output >}}
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           19s
{{< /output >}}

{{% notice info %}}
CPU units are expressed as 1 CPU or 1000m, which equals to 1vCPU/Core. Additional details can be found [here](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) 
{{% /notice %}}
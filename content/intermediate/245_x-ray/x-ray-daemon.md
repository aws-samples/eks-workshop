---
title: "Deploy X-Ray DaemonSet"
date: 2018-11-177T08:30:11-07:00
weight: 11
draft: false
---

Now that we have modified the IAM role for the worker nodes to permit write operations to the X-Ray service, we are going to deploy the X-Ray [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) to the EKS cluster. The X-Ray daemon will be deployed to each worker node in the EKS cluster. For reference, see the [example implementation](https://github.com/aws-samples/eks-workshop/tree/master/content/intermediate/245_x-ray/daemonset.files) used in this module.

The [AWS X-Ray SDKs](https://docs.aws.amazon.com/xray/index.html#lang/en_us) are used to instrument your microservices. When using the DaemonSet in the [example implementation](https://github.com/aws-samples/eks-workshop/tree/master/content/intermediate/245_x-ray/daemonset.files), you need to configure it to point to **xray-service.default:2000**.

The following showcases how to configure the [X-Ray SDK for Go](https://docs.aws.amazon.com/xray/latest/devguide/xray-sdk-go.html). This is merely an example and not a required step in the workshop.

```
func init() {
	xray.Configure(xray.Config{
		DaemonAddr:     "xray-service.default:2000",
		LogLevel:       "info",
	})
}
```

To deploy the X-Ray DaemonSet:

```
kubectl create -f https://eksworkshop.com/intermediate/245_x-ray/daemonset.files/xray-k8s-daemonset.yaml
```

To see the status of the X-Ray DaemonSet:

```
kubectl describe daemonset xray-daemon
```

The folllowing is an example of the command output:

![GitHub Edit](/images/x-ray/daemon_status.png)

{{% notice tip %}}
To view the logs for all of the X-Ray daemon pods run the following
{{% /notice %}}

```
kubectl logs -l app=xray-daemon
```



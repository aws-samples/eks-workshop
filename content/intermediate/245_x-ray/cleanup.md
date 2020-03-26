---
title: "Cleanup"
date: 2018-10-087T08:30:11-07:00
weight: 14
draft: false
---

Congratulations on completing the Tracing with X-Ray module.

The content for this module was based on the [Application Tracing on Kubernetes with AWS X-Ray](https://aws.amazon.com/blogs/compute/application-tracing-on-kubernetes-with-aws-x-ray/) blog post.

This module is not used in subsequent steps, so you can remove the resources now or at the end of the workshop.

Delete the Kubernetes example microservices deployed:

```
kubectl delete deployments x-ray-sample-front-k8s x-ray-sample-back-k8s

kubectl delete services x-ray-sample-front-k8s x-ray-sample-back-k8s
```

Delete the X-Ray DaemonSet:

```
kubectl delete -f https://eksworkshop.com/intermediate/245_x-ray/daemonset.files/xray-k8s-daemonset.yaml
```

```
aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess
```

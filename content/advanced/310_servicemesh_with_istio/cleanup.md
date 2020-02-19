---
title: "Cleanup"
date: 2019-03-20T13:59:44+01:00
weight: 70
draft: false
---

To cleanup, follow the below steps.

To remove telemetry configuration / port-forward process

```
kubectl delete -f istio-telemetry.yaml
```

To remove the application virtual services / destination rules

```
kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml

kubectl delete -f samples/bookinfo/networking/destination-rule-all.yaml
```

To remove the gateway / application

```
kubectl delete -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
```

To remove Istio

```
helm uninstall istio --namespace istio-system
helm uninstall istio-init --namespace istio-system
```


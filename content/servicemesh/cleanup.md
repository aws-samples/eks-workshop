---
title: "Cleanup"
date: 2018-11-13T23:59:44+09:00
weight: 70
draft: false
---

#### Remove telemetry configuration / port-forward process

```
kubectl delete -f istio-telemetry.yaml

killall kubectl
```

#### Remove the application virtual services / destination rules

```
kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml

kubectl delete -f samples/bookinfo/networking/destination-rule-all.yaml
```

#### Remove the gateway / application

```
kubectl delete -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl delete -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)
```

#### Remove the Istio

```
kubectl delete -f istio.yaml

kubectl delete -f install/kubernetes/helm/istio/templates/crds.yaml

kubectl delete namespace istio-system
```


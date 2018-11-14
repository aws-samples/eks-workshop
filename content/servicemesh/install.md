---
title: "Install Istio"
date: 2018-11-13T16:36:55+09:00
weight: 30
draft: true
---

### Install Istio's CRD
The CRD(Custom Resource Definition) API resource allows you to define custom resources. To find more about CRD click [here](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions).

```
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
```

### Install Istio
Make sure you have Helm to install Istio into your EKS Cluster.

```
kubectl create -f install/kubernetes/helm/helm-service-account.yaml

helm template install/kubernetes/helm/istio --name istio --namespace istio-system --set global.configValidation=false --set sidecarInjectorWebhook.enabled=false --set grafana.enabled=true --set servicegraph.enabled=true > istio.yaml

kubectl create namespace istio-system

kubectl apply -f istio.yaml

kubectl get pod -n istio-system
```

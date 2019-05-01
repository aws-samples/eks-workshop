---
title: "Install Istio"
date: 2019-03-20T13:36:55+01:00
weight: 30
draft: false
---

### Define service account for Tiller
Helm and Tiller are required for the following examples. If you have not installed Helm yet, [please first reference the Helm chapter](/helm_root) before proceeding.

First create a service account for Tiller:
```
kubectl apply -f install/kubernetes/helm/helm-service-account.yaml
```

### Install Istio CRDs
The [Custom Resource Definitions, also known as CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions) are API resources which allow you to define custom resources. 
```
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
```

You can check the installation by running:
```
kubectl get crds --namespace istio-system | grep 'istio.io'
```
This should return around 50 CRDs. 


### Install Istio
The last step installs Istio's core components:

```
helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set global.configValidation=false --set sidecarInjectorWebhook.enabled=false --set grafana.enabled=true --set servicegraph.enabled=true
```

You can verify that the services have been deployed using
```
kubectl get svc -n istio-system
```
and check the corresponding pods with:
```
kubectl get pods -n istio-system
```

```
NAME                                    READY     STATUS      RESTARTS   AGE
grafana-7b46bf6b7c-4rh5z                1/1       Running     0          10m
istio-citadel-75fdb679db-jnn4z          1/1       Running     0          10m
istio-galley-c864b5c86-sq952            1/1       Running     0          10m
istio-ingressgateway-668676fbdb-p5c8c   1/1       Running     0          10m
istio-init-crd-10-zgzn9                 0/1       Completed   0          12m
istio-init-crd-11-9v626                 0/1       Completed   0          12m
istio-pilot-f4c98cfbf-v8bss             2/2       Running     0          10m
istio-policy-6cbbd844dd-ccnph           2/2       Running     1          10m
istio-telemetry-ccc4df498-pjht7         2/2       Running     1          10m
prometheus-89bc5668c-f866j              1/1       Running     0          10m
servicegraph-5d4b49848-qvdtr            1/1       Running     0          10m
```

---
title: "Cleanup"
date: 2021-01-27T08:30:11-07:00
weight: 60
draft: false
---

#### Delete Flagger Resources

```bash
kubectl delete canary detail -n  flagger
helm uninstall flagger-loadtester -n flagger
kubectl delete HorizontalPodAutoscaler detail -n flagger
kubectl delete deployment detail -n  flagger
```

#### Delete Flagger Namespace

{{% notice info %}}
Namespace deletion may take few minutes, please wait till the process completes.
{{% /notice %}}

```bash
kubectl delete namespace flagger
```

#### Delete the Mesh

```bash
kubectl delete meshes flagger
```

#### Delete Policies and Service Accounts for `flagger` namespace

```bash
aws iam delete-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/FlaggerEnvoyNamespaceIAMPolicy
eksctl delete iamserviceaccount  --cluster eksworkshop-eksctl --namespace flagger --name flagger-envoy-proxies
```

#### Uninstall the Flagger Helm Charts

```bash
helm -n appmesh-system delete flagger
```

#### Delete Flagger CRDs

```bash
for i in $(kubectl get crd | grep flagger | cut -d" " -f1) ; do
kubectl delete crd $i
done
```

#### Uninstall Prometheus Helm Charts

```bash
helm -n appmesh-system delete appmesh-prometheus
```

#### Uninstall Metric Server

```bash
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
```

#### Uninstall AppMesh 

```bash

helm -n appmesh-system delete appmesh-controller
for i in $(kubectl get crd | grep appmesh | cut -d" " -f1) ; do
kubectl delete crd $i
done
eksctl delete iamserviceaccount  --cluster eksworkshop-eksctl --namespace appmesh-system --name appmesh-controller
kubectl delete namespace appmesh-system
```

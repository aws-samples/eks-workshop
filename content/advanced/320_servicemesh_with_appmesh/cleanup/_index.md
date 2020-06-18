---
title: "App Mesh Cleanup"
date: 2018-11-13T16:32:30+09:00
weight: 100
draft: false
---

## Delete DJ App

```bash
kubectl delete namespace prod
```

## Delete the dj-app mesh

```bash
kubectl delete meshes dj-app
```

## Uninstall the Helm Charts

```bash
helm -n appmesh-system delete appmesh-controller
```

## Delete AWS App Mesh CRDs

```bash
for i in $(kubectl get crd | grep appmesh | cut -d" " -f1) ; do
kubectl delete crd $i
done
```

## Delete the AWS App Mesh namespace

```bash
kubectl delete namespace appmesh-system
```

---
title: "App Mesh Cleanup"
date: 2018-11-13T16:32:30+09:00
weight: 40
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
helm -n appmesh-system delete appmesh-inject
helm -n appmesh-system delete appmesh-controller
```

## Delete AWS App Mesh CRDs

```bash
kubectl delete -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/appmesh-controller/crds/crds.yaml
```

## Delete the AWS App Mesh namespace

```bash
kubectl delete namespace appmesh-system
```

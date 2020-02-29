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

## Uninstall the Helm Charts

```bash
helm -n appmesh-system delete appmesh-inject
helm -n appmesh-system delete appmesh-controller
```

## Delete mesh

```bash
aws appmesh delete-mesh --mesh-name dj-app
```

## Delete the AWS App Mesh namespace

```bash
kubectl delete namespace appmesh-system
```

## Delete AWS App Mesh CRDs

```bash
kubectl delete -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/appmesh-controller/crds/crds.yaml
```

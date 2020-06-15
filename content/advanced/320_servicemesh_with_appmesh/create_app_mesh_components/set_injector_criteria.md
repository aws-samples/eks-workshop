---
title: "Sidecar Injection"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

You enable sidecar injection for a Kubernetes namespace. When necessary, you can override the injector's default behavior for each pod you deploy in a Kubernetes namespace that you've enabled the injector for.

## Enable Sidecar Injection for a Namespace

To enable the sidecar injector for a Kubernetes namespace, label the namespace with the following command.

```bash
kubectl label \
  namespace prod appmesh.k8s.aws/sidecarInjectorWebhook=enabled
```

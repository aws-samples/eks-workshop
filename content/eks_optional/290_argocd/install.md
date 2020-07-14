---
title: "Install Argo CD"
weight: 10
draft: false
---

### ArgoCD Architecture
![ArgoCD Architecture](/images/argocd/argocd_architecture.png)

ArgoCD is composed of three mains components:

***API Server***: Exposes the API for the WebUI / CLI / CICD Systems

***Repository Server***: Internal service which maintains a local cache of the git repository holding the application manifests

***Application Controller***: Kubernetes controller which controls and monitors applications continuously and compares that  current live state with desired target state (specified in the repository). If a `OutOfSync` is detected, it will take corrective actions.

### Install Argo CD

All those components could be installed using a manifest provided by the Argo Project:

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Install Argo CD CLI

To interact with the `API Server` we need to deploy the CLI:

```
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

sudo chmod +x /usr/local/bin/argocd
```

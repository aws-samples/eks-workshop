---
title: "Install Helm CLI"
date: 2018-08-07T08:30:11-07:00
weight: 5
---

Before we can get started configuring `helm` we'll need to first install the command line tools that you will interact with. To do this run the following.

```
cd ~/environment

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

```

Activate helm bash-completion

```
source <(helm completion bash)
```

Add official Helm Chart Repository

```
 helm repo add stable https://kubernetes-charts.storage.googleapis.com
 ```
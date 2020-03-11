---
title: "Download and Install Istio CLI"
date: 2018-11-13T16:36:43+09:00
weight: 20
draft: false
---

Before we can get started configuring Istio we’ll need to first install the command line tools that you will interact with. To do this run the following.

{{% notice info %}}
We will use Istio's latest release version.
{{% /notice %}}

```bash
echo 'export ISTIO_VERSION='$(curl -L -s https://api.github.com/repos/istio/istio/releases | grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/" | grep -v -E "(alpha|beta|rc)\.[0-9]$" | sort -t"." -k 1,1 -k 2,2 -k 3,3 -k 4,4 | tail -n 1) >> ${HOME}/.bash_profile

source ${HOME}/.bash_profile
```

```bash
cd ~/environment
curl -L https://istio.io/downloadIstio | sh -
```

The installation directory contains:

* Installation YAML files for Kubernetes in install/kubernetes
* Sample applications in `samples/`
* The `istioctl` client binary in the `bin/` directory (`istioctl` is used when manually injecting Envoy as a sidecar proxy).

```bash
cd ${HOME}/environment/istio-${ISTIO_VERSION}

sudo cp -v bin/istioctl /usr/local/bin/
```

We can verify that we have the proper version in our $PATH

```bash
istioctl version --remote=false
```

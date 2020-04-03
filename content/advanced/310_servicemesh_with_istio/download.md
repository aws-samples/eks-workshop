---
title: "Download and Install Istio CLI"
date: 2018-11-13T16:36:43+09:00
weight: 20
draft: false
---

Before we can get started configuring Istio we’ll need to first install the command line tools that you will interact with. To do this run the following.

{{% notice info %}}
We will use istio version `1.5.1`
{{% /notice %}}

```bash
echo 'export ISTIO_VERSION="1.5.1"' >> ${HOME}/.bash_profile
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

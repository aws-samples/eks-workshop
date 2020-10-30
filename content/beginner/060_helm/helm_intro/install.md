---
title: "Install Helm CLI"
date: 2018-08-07T08:30:11-07:00
weight: 5
---
## Install the Helm CLI

Before we can get started configuring Helm, we'll need to first install the
command line tools that you will interact with. To do this, run the following:

```sh
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

We can verify the version

```sh
helm version --short
```

Let's configure our first Chart repository. Chart repositories are similar to
APT or yum repositories that you might be familiar with on Linux, or Taps for
Homebrew on macOS.

Download the `stable` repository so we have something to start with:

```sh
helm repo add stable https://charts.helm.sh/stable
```

Once this is installed, we will be able to list the charts you can install:

```sh
helm search repo stable
```

Finally, let's configure Bash completion for the `helm` command:

```sh
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)
```

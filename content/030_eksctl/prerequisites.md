---
title: "Prerequisites"
date: 2018-08-07T13:31:55-07:00
weight: 10
---

For this module, we need to use the [eksctl](https://eksctl.io/) command:

You will have it already installed if you [**created the Cloud9 Environment automatically**](/020_prerequisites/automatic_cloud9/workspace/)


If you [**created the Cloud Workspace step by step**](/020_prerequisites/step-by-step/workspace/)
you need to download and install first. 

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin
```

In both cases confirm the eksctl command works:

```bash
eksctl version
```

If you **created the Cloud Workspace step by step**, enable eksctl bash-completion

```bash
eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
```

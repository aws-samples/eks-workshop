---
title: "Prerequisites"
date: 2018-08-07T13:31:55-07:00
weight: 10
---

For this module, we need to download the [eksctl](https://eksctl.io/) binary:

#### Install eksctl
```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin
sudo chmod +x /usr/local/bin/eksctl
```

Confirm the eksctl command works:

```bash
eksctl version
```

Enable eksctl bash-completion

```bash
eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
```

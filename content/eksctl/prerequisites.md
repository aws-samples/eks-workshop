---
title: "Prerequisites"
date: 2018-08-07T13:31:55-07:00
weight: 10
---

For this module, we need to download the [eksctl](https://eksctl.io/) binary:
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.9.0/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin
```

Confirm the eksctl command works:
```
eksctl version
```

Enable eksctl bash-completion
```
eksctl completion bash >> ~/.bash_completion
```

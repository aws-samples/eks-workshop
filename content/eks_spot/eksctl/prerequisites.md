---
title: "Prerequisites"
date: 2018-08-07T13:31:55-07:00
weight: 10
---

For this module, we need to download the [eksctl](https://eksctl.io/) binary:
```
export EKSCTL_VERSION=0.23.0
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
```

Confirm the eksctl command works:
```
eksctl version  
```

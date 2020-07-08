---
title: "Install Argo CLI"
date: 2018-11-18T00:00:00-05:00
weight: 30
draft: false
---

### Install Argo CLI

Before we can get started configuring `argo` we'll need to first install the
command line tools that you will interact with. To do this run the following.

```bash
# set argo version
export ARGO_VERSION="v2.9.1"
```

```bash
# Download the binary
sudo curl -sSL -o /usr/local/bin/argo https://github.com/argoproj/argo/releases/download/${ARGO_VERSION}/argo-linux-amd64

# Make binary executable
sudo chmod +x /usr/local/bin/argo

# Test installation
argo version --short
```

output
{{< output >}}
argo: v2.9.1
{{< /output >}}

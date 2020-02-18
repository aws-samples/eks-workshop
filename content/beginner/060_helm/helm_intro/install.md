---
title: "Install Helm CLI"
date: 2018-08-07T08:30:11-07:00
weight: 5
---
# Install the Helm CLI

Before we can get started configuring `Helm` we'll need to first install the command line tools that you will interact with. To do this run the following.
```sh
cd ~/environment
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh

./get_helm.sh
```

We can verify the version
```sh
helm version --short
```

Now that the `Helm Client` successfully installed, we can add the stable repo.
```sh
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```

Once this is installed, we will be able to list the charts you can install
```sh
helm search repo stable
```

Finally, let's activate `Helm` bash-completion
```sh
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
```
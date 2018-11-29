---
title: "Install Helm CLI"
date: 2018-08-07T08:30:11-07:00
weight: 5
draft: false
---

Before we can get started configuring `helm` we'll need to first install the
command line tools that you will interact with. To do this run the following.

```bash
cd ~/environment

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh

chmod +x get_helm.sh

./get_helm.sh
```

{{% notice info %}}
Once you install helm, the command will prompt you to run 'helm init'. **Do not run 'helm init' yet.** Follow the instructions in the next section and then install tiller as specified.
If you accidentally run 'helm init', you can safely uninstall tiller by running 'helm reset --force'
{{% /notice %}}

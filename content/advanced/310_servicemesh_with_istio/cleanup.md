---
title: "Cleanup"
date: 2019-03-20T13:59:44+01:00
weight: 70
draft: false
---

To cleanup, follow the below steps.

Terminate any `kubectl port-forward` or `watch` processes

```bash
killall kubectl
killall watch
```

When you’re finished experimenting with the `Bookinfo` sample, uninstall and clean it up using the following instructions

```bash
export NAMESPACE="bookinfo"

${HOME}/environment/istio-${ISTIO_VERSION}/samples/bookinfo/platform/kube/cleanup.sh

kubectl delete ns bookinfo
```

`istioctl` will delete:

* The RBAC permissions
* The `istio-system` namespace
* All resources hierarchically under it

{{% notice info %}}
you can ignore the errors for non-existent resources because they may have been deleted hierarchically.
{{% /notice %}}

```bash
istioctl manifest generate --set profile=demo | kubectl delete -f -
```

Finally, we can delete the istio folder and clean up the `~/.bash_profile`.

```bash
cd ~/environment
rm -rf istio-${ISTIO_VERSION}

sed -i '/ISTIO_VERSION/d' ${HOME}/.bash_profile
unset ISTIO_VERSION
```

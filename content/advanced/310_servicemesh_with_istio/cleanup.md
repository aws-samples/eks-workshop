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
export ISTIO_RELEASE=$(echo $ISTIO_VERSION |cut -d. -f1,2)

kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_RELEASE}/samples/addons/jaeger.yaml

kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_RELEASE}/samples/addons/kiali.yaml

kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_RELEASE}/samples/addons/prometheus.yaml

kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_RELEASE}/samples/addons/grafana.yaml

export NAMESPACE="bookinfo"

${HOME}/environment/istio-${ISTIO_VERSION}/samples/bookinfo/platform/kube/cleanup.sh


istioctl manifest generate --set profile=demo | kubectl delete -f -

kubectl delete ns bookinfo
kubectl delete ns istio-system
```

{{% notice info %}}
You can ignore the errors for non-existent resources because they may have been deleted hierarchically.
{{% /notice %}}

Finally, we can delete the istio folder and clean up the `~/.bash_profile`.

```bash
cd ~/environment
rm -rf istio-${ISTIO_VERSION}

sed -i '/ISTIO_VERSION/d' ${HOME}/.bash_profile
unset ISTIO_VERSION
```

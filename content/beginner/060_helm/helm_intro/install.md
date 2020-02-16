---
title: "Install Helm CLI"
date: 2018-08-07T08:30:11-07:00
weight: 5
---

Before we can deploy [charts](https://helm.sh/docs/topics/charts/) with `Helm` we'll need to:
  * Configure Helm access with RBAC
  * Install the command line tools that you will interact with.

## Configure Helm access with RBAC

`Helm` relies on a service called **tiller** that requires special permission on the kubernetes cluster, so we need to create a _**Service Account**_ for **tiller**.

To create a new service account manifest:
```bash
cat <<EoF > ~/environment/heml-rbac.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EoF

# we can now apply the rbac config for helm
kubectl apply -f ~/environment/helm-rbac.yaml
```


## Install the Helm client

{{% notice warning %}}
Once you install helm, the command will prompt you to run `helm init`. **Do not run this command**.
If you accidentally run 'helm init', you can safely uninstall tiller by running `helm reset --force`
{{% /notice %}}

```bash
cd ~/environment

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh

chmod +x get_helm.sh

./get_helm.sh
```


## Install **tiller** using the **helm** tooling

```bash
helm init --service-account tiller
```

This will install **tiller** into the cluster which gives it access to manage resources in your cluster.

Activate helm bash-completion

```
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
```

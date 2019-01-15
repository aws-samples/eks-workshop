---
title: "Install Helm CLI"
date: 2018-08-07T08:30:11-07:00
weight: 5
---

Before we can get started configuring `helm` we'll need to first install the command line tools that you will interact with. To do this run the following.

```
cd ~/environment

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh

chmod +x get_helm.sh

./get_helm.sh
```

{{% notice info %}}
Once you install helm, the command will prompt you to run 'helm init'. **Do not run 'helm init'.** Follow the instructions to configure helm using **Kubernetes RBAC** and then install tiller as specified below
If you accidentally run 'helm init', you can safely uninstall tiller by running 'helm reset --force'
{{% /notice %}}

### Configure Helm access with RBAC

Helm relies on a service called **tiller** that requires special permission on the
kubernetes cluster, so we need to build a _**Service Account**_ for **tiller**
to use. We'll then apply this to the cluster.

To create a new service account manifest:
```
cat <<EoF > ~/environment/rbac.yaml
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
```

Next apply the config:
```
kubectl apply -f ~/environment/rbac.yaml
```

Then we can install **helm** using the **helm** tooling

```
helm init --service-account tiller
```

This will install **tiller** into the cluster which gives it access to manage
resources in your cluster.

---
title: "Deploy Helm"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

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

---
title: "Deploy Calico on the Cluster"
date: 2018-11-08T08:30:11-07:00
weight: 1
---

Install the Calico helm chart. This installs an operator in the tigera-operator namespace, which will then install Calico in the calico-system namespace.

1. Add the helm repository

```
helm repo add projectcalico https://docs.projectcalico.org/charts
```

1. If you already have Calico added, you may want to update it to get the latest released version.

```
helm repo update
```

1. Install version 3.21.4 or later of the Tigera Calico operator and custom resource definitions.

```
helm install calico projectcalico/tigera-operator --version v3.21.4
```

Watch the calico-system daemon sets and wait for the calico-node daemon set to have the DESIRED number of pods in the READY state.

```
kubectl get daemonset calico-node --namespace=calico-system
```

Expected Output:

{{< output >}}
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
calico-node   3         3         3       3            3           <none>          38s
{{< /output >}}


For linux OS containers, this would be all we need to install Calico; however, for Windows we need to add a rolebinding to allow the windows nodes to install Calico.

Create the user-rolebinding.yaml file

```
cat << EOF > ~/environment/windows/user-rolebinding.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: nodes-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:nodes
EOF
```

Apply the user role binding to the cluster

```
kubectl apply -f ~/environment/windows/user-rolebinding.yaml
```

Calico is now ready to use in the cluster!

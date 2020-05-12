---
title: "Deploy Argo"
date: 2018-11-18T00:00:00-05:00
weight: 40
draft: false
---

### Deploy Argo

Argo run in its own namespace and deploys as a CustomResourceDefinition.

Deploy the Controller and UI.

```bash
kubectl create namespace argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/v2.2.1/manifests/install.yaml
```

{{< output >}}
namespace/argo created
customresourcedefinition.apiextensions.k8s.io/workflows.argoproj.io created
serviceaccount/argo created
serviceaccount/argo-ui created
clusterrole.rbac.authorization.k8s.io/argo-aggregate-to-admin created
clusterrole.rbac.authorization.k8s.io/argo-aggregate-to-edit created
clusterrole.rbac.authorization.k8s.io/argo-aggregate-to-view created
clusterrole.rbac.authorization.k8s.io/argo-cluster-role created
clusterrole.rbac.authorization.k8s.io/argo-ui-cluster-role created
clusterrolebinding.rbac.authorization.k8s.io/argo-binding created
clusterrolebinding.rbac.authorization.k8s.io/argo-ui-binding created
configmap/workflow-controller-configmap created
service/argo-ui created
deployment.apps/argo-ui created
deployment.apps/workflow-controller created
{{< /output >}}

To use advanced features of Argo for this demo, create a RoleBinding to grant admin privileges to the 'default' service account.

{{% notice warning %}}
This is for demo purposes only. In any other environment, you should use [Workflow RBAC](https://github.com/argoproj/argo/blob/master/docs/workflow-rbac.md) to set appropriate permissions.
{{% /notice %}}

```bash
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default
```

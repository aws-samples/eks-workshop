---
title: "Adding the CRDs"
date: 2018-08-07T08:30:11-07:00
weight: 60
---

There are two ways to create the components of the App Mesh service mesh:

1. With the AWS CLI
2. With kubectl via CRDs

For this tutorial, we'll use kubectl to define the App Mesh components.  

To do this, we'll add Custom Resource Definitions (CRDs), and the App Mesh controller logic that syncs our kubernetes cluster's CRD state with the AWS cloud-side App Mesh control plane.

To add the CRDs, from the repository base directory, execute the following commands:

```
kubectl apply -f 3_add_crds/mesh-definition.yaml
kubectl apply -f 3_add_crds/virtual-node-definition.yaml
kubectl apply -f 3_add_crds/virtual-service-definition.yaml
```

Output should be similar to:

```
customresourcedefinition.apiextensions.k8s.io/meshes.appmesh.k8s.aws (http://customresourcedefinition.apiextensions.k8s.io/meshes.appmesh.k8s.aws) created
customresourcedefinition.apiextensions.k8s.io/virtualnodes.appmesh.k8s.aws (http://customresourcedefinition.apiextensions.k8s.io/virtualnodes.appmesh.k8s.aws) created
customresourcedefinition.apiextensions.k8s.io/virtualservices.appmesh.k8s.aws (http://customresourcedefinition.apiextensions.k8s.io/virtualservices.appmesh.k8s.aws) created
```

Next, add the controller by executing the following command:

```
kubectl apply -f 3_add_crds/controller-deployment.yaml
```

Output should be similar to:

```
namespace/appmesh-system created
deployment.apps/app-mesh-controller created
serviceaccount/app-mesh-sa created
clusterrole.rbac.authorization.k8s.io/app-mesh-controller (http://clusterrole.rbac.authorization.k8s.io/app-mesh-controller) created
clusterrolebinding.rbac.authorization.k8s.io/app-mesh-controller-binding (http://clusterrolebinding.rbac.authorization.k8s.io/app-mesh-controller-binding) created
```

Execute the following command to verify the App Mesh Controller is running:

```
kubectl get pods -nappmesh-system
```

You should see output similar to:

```
NAME                                   READY   STATUS    RESTARTS   AGE
app-mesh-controller-85f9d4b48f-j9vz4   1/1     Running   0          7m

```

*NOTE*:  [The CRD](https://github.com/aws/aws-app-mesh-controller-for-k8s) and [Injector](https://github.com/aws/aws-app-mesh-inject) are AWS supported open source projects.  If you plan to deploy the CRD and/or Injector for production projects, always build them from the latest AWS Github repos to stay up to date on the latest features and bug fixes, and deploy them from your own container registry.

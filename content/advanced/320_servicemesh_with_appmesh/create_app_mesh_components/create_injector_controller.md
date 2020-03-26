---
title: "Configure App Mesh Integration "
date: 2018-08-07T08:30:11-07:00
weight: 40
---

## Helm V3

{{% notice warning %}}
If the command below gives you an error, [follow this link](/beginner/060_helm/helm_intro/install/) to install the latest version of Helm.
{{% /notice %}}

```bash
helm version --short
```

We can add the EKS repository to Helm

```bash
helm repo add eks https://aws.github.io/eks-charts

helm repo list | grep eks-charts
```

{{< output >}}
eks     https://aws.github.io/eks-charts
{{< /output >}}

## Install the Controller and Custom Resource

We will deploy all the `AWS App Mesh` Components into the appmesh-system namespace

Let's create the namespace

```bash
kubectl create ns appmesh-system
```

Now we can apply the `AWS App Mesh` CRDs

```bash
kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/appmesh-controller/crds/crds.yaml

kubectl get crd | grep appmesh
```

{{< output >}}
meshes.appmesh.k8s.aws             2020-02-29T02:43:15Z
virtualnodes.appmesh.k8s.aws       2020-02-29T02:43:15Z
virtualservices.appmesh.k8s.aws    2020-02-29T02:43:15Z
{{< /output >}}

Next, we will attach the IAM Policy `AWSAppMeshFullAccess` to the `appmesh-controller`.

{{% notice tip %}}
if you are new to the `IAM Roles for Service Accounts (IRSA)` concept, [Click here](/beginner/110_irsa/) for me information.
{{% /notice %}}

```bash
# Create your OIDC identity provider for the cluster
eksctl utils associate-iam-oidc-provider \
  --cluster eksworkshop-eksctl \
  --approve

# Create an IAM role for the appmesh-controller service account
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace appmesh-system \
  --name appmesh-controller \
  --attach-policy-arn  arn:aws:iam::aws:policy/AWSCloudMapFullAccess,arn:aws:iam::aws:policy/AWSAppMeshFullAccess \
  --override-existing-serviceaccounts \
  --approve
```

Finally we will use `Helm` to deploy the appmesh-controller

```bash
helm upgrade -i appmesh-controller eks/appmesh-controller \
  --namespace appmesh-system \
  --set region=${AWS_REGION} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=appmesh-controller
```

## Install the Sidecar Injector

We will use `Helm` to deploy the injector and create the mesh at install time.

{{% notice info %}}
We will use `dj-app` as the mesh name
{{% /notice %}}

```bash
export APPMESH_NAME="dj-app"

helm upgrade -i appmesh-inject eks/appmesh-inject \
  --namespace appmesh-system \
  --set mesh.name=${APPMESH_NAME} \
  --set mesh.create=true
```

Let's list all the components installed in the `app-mesh` namespace

```bash
kubectl -n appmesh-system get deploy,pods,service
```

The output should be similar to this

{{< output >}}
sh-system get deploy,pods,service
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/appmesh-controller   1/1     1            1           22m
deployment.extensions/appmesh-inject       1/1     1            1           91s

NAME                                      READY   STATUS    RESTARTS   AGE
pod/appmesh-controller-7478cb4958-5lrx5   1/1     Running   0          22m
pod/appmesh-inject-78844456d7-rj65c       1/1     Running   0          91s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/appmesh-inject   ClusterIP   10.100.13.21   <none>        443/TCP   91s
{{< /output >}}

Finally we can verify that the mesh has been created:

* Using the awscli

```bash
aws appmesh list-meshes | jq '.meshes[].meshName'
```

{{< output >}}
"dj-app"
{{< /output >}}

* Or using kubectl

```bash
kubectl -n prod get meshes
```

{{< output >}}
NAME     AGE
dj-app   17m
{{< /output >}}

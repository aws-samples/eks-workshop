---
title: "Install the App Mesh Controller"
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

The AWS App Mesh Controller for Kubernetes is easily installed using Helm. To get started, add the EKS Charts repository.

```bash
helm repo add eks https://aws.github.io/eks-charts

helm repo list | grep eks-charts
```

{{< output >}}
eks     https://aws.github.io/eks-charts
{{< /output >}}

Create the `appmesh-system` namespace and attach IAM Policies for AWS App Mesh and AWS Cloud Map full access.

{{% notice tip %}}
if you are new to the `IAM Roles for Service Accounts (IRSA)` concept, [Click here](/beginner/110_irsa/) for me information.
{{% /notice %}}

```bash
kubectl create ns appmesh-system

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

Now install App Mesh Controller into the `appmesh-system` namespace using the project's Helm chart.

```bash
helm upgrade -i appmesh-controller eks/appmesh-controller \
  --namespace appmesh-system \
  --set region=${AWS_REGION} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=appmesh-controller
```

Now list all resources in the `appmesh-system` namespace and verify the installation was successful.

```bash
kubectl -n appmesh-system get all
```

The output should be similar to this:

{{< output >}}
NAME                                   READY   STATUS    RESTARTS   AGE
pod/appmesh-controller-866f8b8cdf-twkcq   1/1     Running   0          2m

NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/appmesh-controller-webhook-service   ClusterIP   10.100.209.34   <none>        443/TCP   2m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/appmesh-controller        1/1     1            1           2m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/appmesh-controller-866f8b8cdf   1         1         1       2m
{{< /output >}}

You can also see that the App Mesh Custom Resource Definitions were installed.

```bash
kubectl get crds | grep appmesh
```

{{< output >}}
NAME                               READY   STATUS    RESTARTS   AGE
meshes.appmesh.k8s.aws             2020-06-17T20:46:06Z
virtualnodes.appmesh.k8s.aws       2020-06-17T20:46:07Z
virtualrouters.appmesh.k8s.aws     2020-06-17T20:46:07Z
virtualservices.appmesh.k8s.aws    2020-06-17T20:46:06Z
{{< /output >}}

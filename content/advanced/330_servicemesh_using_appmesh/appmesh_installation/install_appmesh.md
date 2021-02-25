---
title: "Installation of AWS App Mesh Controller"
date: 2020-01-27T08:30:11-07:00
weight: 40
draft: false
---
      
#### Install App Mesh Helm Chart

Check that Helm is installed. 

```
helm list
```

This command should either return a list of helm charts that have already been deployed or nothing.

{{% notice info %}}
If you get an error message, see [installing helm](/beginner/060_helm/helm_intro/install/index.html) for instructions.
{{% /notice %}}

Add EKS Helm Repo
  The AWS App Mesh Controller for Kubernetes is easily installed using Helm. To get started, add the EKS Charts repository.
```bash
helm repo add eks https://aws.github.io/eks-charts
```
{{< output >}}
"eks" has been added to your repositories
{{< /output >}}

Update Helm Repo
```bash
helm repo update
```
{{< output >}}
....
Update Complete. ⎈Happy Helming!⎈
{{< /output >}}

#### Install App Mesh Controller

Create the appmesh-system namespace and attach IAM Policies for AWS App Mesh and AWS Cloud Map full access.
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

Install App Mesh Controller into the appmesh-system namespace with X-Ray enabled

```bash
helm upgrade -i appmesh-controller eks/appmesh-controller \
    --namespace appmesh-system \
    --set region=$AWS_REGION \
    --set serviceAccount.create=false \
    --set serviceAccount.name=appmesh-controller \
    --set tracing.enabled=true \
    --set tracing.provider=x-ray
```
{{< output >}}
Release "appmesh-controller" has been upgraded. Happy Helming!     
NAME: appmesh-controller     
LAST DEPLOYED: Wed Jan 20 21:07:01 2021     
NAMESPACE: appmesh-system     
STATUS: deployed     
REVISION: 1    
TEST SUITE: None     
NOTES:     
AWS App Mesh controller installed! 
{{< /output >}}

Confirm that the controller version is v1.0.0 or later.

```bash
kubectl get deployment appmesh-controller \
    -n appmesh-system \
    -o json  | jq -r ".spec.template.spec.containers[].image" | cut -f2 -d ':'
```
{{< output >}} 
v1.3.0
{{< /output >}}

Confirm all the resources are created in the App Mesh

```bash
kubectl get crds | grep appmesh
```
{{< output >}}
gatewayroutes.appmesh.k8s.aws                2020-11-02T16:02:14Z
meshes.appmesh.k8s.aws                       2020-11-02T16:02:15Z
virtualgateways.appmesh.k8s.aws              2020-11-02T16:02:15Z
virtualnodes.appmesh.k8s.aws                 2020-11-02T16:02:15Z
virtualrouters.appmesh.k8s.aws               2020-11-02T16:02:15Z
virtualservices.appmesh.k8s.aws              2020-11-02T16:02:15Z    
{{< /output >}}

Get all the resources created in appmesh-system Namespace

```bash
kubectl -n appmesh-system get all          
```
{{< output >}}  
NAME                                     READY   STATUS    RESTARTS   AGE     
pod/appmesh-controller-fcc7c4ffc-mldhk   1/1     Running   0          47s 
NAME                                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     
service/appmesh-controller-webhook-service   ClusterIP   10.100.xx.yy   <none>        443/TCP   27m å   
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE     
deployment.apps/appmesh-controller   1/1     1            1           27m 
NAME                                            D kubectl get crds ESIRED   CURRENT   READY   AGE    
replicaset.apps/appmesh-controller-fcc7c4ffc    1         1         1       47s 
{{< /output >}}

Congratulations on installing the AWS App Mesh Controller for Kubernetes in your cluster!

Next, we'll enable observability, analytics, and routing functionality into our Product Catalog App by porting it to run within App Mesh, and we'll demonstrate how to simplify various types of deployments.


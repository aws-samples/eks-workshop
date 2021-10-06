---
title: "Cleanup"
date: 2020-01-27T08:30:11-07:00
weight: 100
draft: false
---

{{% notice info %}}
Namespace deletion may take few minutes, please wait till the process completes.
{{% /notice %}}

#### Delete Product Catalog apps

```bash
kubectl delete namespace prodcatalog-ns
```

#### Delete ECR images

```bash
aws ecr delete-repository --repository-name eks-app-mesh-demo/catalog_detail --force
aws ecr delete-repository --repository-name eks-app-mesh-demo/frontend_node --force
aws ecr delete-repository --repository-name eks-app-mesh-demo/product_catalog --force
```

#### (Only if you enabled for this workshop) Disable Amazon EKS Control Pane Logs

```bash
eksctl utils update-cluster-logging --disable-types all \
    --region ${AWS_REGION} \
    --cluster eksworkshop-eksctl \
    --approve
```

#### Delete Cloudwatch namespace

```bash
kubectl delete namespace amazon-cloudwatch
```

#### Delete Observability namespace

```bash
kubectl delete namespace aws-observability
```

#### Delete the Product Catalog mesh

```bash
kubectl delete meshes prodcatalog-mesh
```

#### Uninstall the Helm Charts

```bash
helm -n appmesh-system delete appmesh-controller
```

#### Delete AWS App Mesh CRDs

```bash
for i in $(kubectl get crd | grep appmesh | cut -d" " -f1) ; do
kubectl delete crd $i
done
```
#### Delete the AppMesh Controller service account
```bash
eksctl delete iamserviceaccount  --cluster eksworkshop-eksctl --namespace appmesh-system --name appmesh-controller
```

#### Delete the AWS App Mesh namespace

```bash
kubectl delete namespace appmesh-system
```

#### Delete Fargate Logging Policy 

```bash
export PodRole=$(aws eks describe-fargate-profile --cluster-name eksworkshop-eksctl --fargate-profile-name fargate-productcatalog --query 'fargateProfile.podExecutionRoleArn' | sed -n 's/^.*role\/\(.*\)".*$/\1/ p')
aws iam detach-role-policy \
        --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/FluentBitEKSFargate \
        --role-name ${PodRole}
aws iam delete-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/FluentBitEKSFargate
```

#### Delete Fargate profile
```bash
eksctl delete fargateprofile \
  --name fargate-productcatalog \
  --cluster eksworkshop-eksctl
```

#### Delete the policy and IRSA 
```bash
eksctl delete iamserviceaccount --cluster eksworkshop-eksctl   --namespace prodcatalog-ns --name prodcatalog-envoy-proxies
aws iam delete-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/ProdEnvoyNamespaceIAMPolicy
```

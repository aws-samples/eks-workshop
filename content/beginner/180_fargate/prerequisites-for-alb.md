---
title: "Setting up the LB controller"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---

### AWS Load Balancer Controller

The AWS ALB Ingress Controller has been rebranded to [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller).

"AWS Load Balancer Controller" is a [controller](https://kubernetes.io/docs/concepts/architecture/controller/) to help manage Elastic Load Balancers for a Kubernetes cluster.

* It satisfies Kubernetes `Ingress` resources by provisioning Application Load Balancers.
* It satisfies Kubernetes `Service` resources by provisioning Network Load Balancers.

#### Helm

We will use **Helm** to install the ALB Ingress Controller.

Check to see if `helm` is installed:

```bash
helm version
```

{{% notice info %}}
If `Helm` is not found, see [installing helm](/beginner/060_helm/helm_intro/install/index.html) for instructions.
{{% /notice %}}

#### Create IAM OIDC provider

First, we will have to set up an OIDC provider with the cluster.

This step is required to give IAM permissions to a Fargate pod running in the cluster using the IAM for Service Accounts feature.

{{% notice info %}}
Learn more about [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) in the Amazon EKS documentation.
{{% /notice %}}

```bash
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster eksworkshop-eksctl \
    --approve
```

#### Create an IAM policy

The next step is to create the IAM policy that will be used by the AWS Load Balancer Controller.

This policy will be later associated to the Kubernetes Service Account and will allow the controller pods to create and manage the ELB’s resources in your AWS account for you.

```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

#### Create a IAM role and ServiceAccount for the Load Balancer controller

Next, create a Kubernetes Service Account by executing the following command

```bash
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

The above command deploys a CloudFormation template that creates an IAM role and attaches the IAM policy to it.

The IAM role gets associated with a Kubernetes Service Account. You can see details of the service account created with the following command.

```bash
kubectl get sa aws-load-balancer-controller -n kube-system -o yaml
```

Output

{{< output >}}
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/eksctl-eksworkshop-eksctl-addon-iamserviceac-Role1-1MMJRJ4LWWHD8
  creationTimestamp: "2020-12-04T19:31:57Z"
  name: aws-load-balancer-controller
  namespace: kube-system
  resourceVersion: "3094"
  selfLink: /api/v1/namespaces/kube-system/serviceaccounts/aws-load-balancer-controller
  uid: aa940b27-796e-4cda-bbba-fe6ca8207c00
secrets:
- name: aws-load-balancer-controller-token-8pnww
{{< /output >}}

{{% notice info %}}
For more information on IAM Roles for Service Accounts [follow this link](/beginner/110_irsa/).
{{% /notice %}}

#### Install the TargetGroupBinding CRDs

```bash
kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master
```

#### Deploy the Helm chart from the Amazon EKS charts repo

Fist, We will verify if the AWS Load Balancer Controller version has beed set

```bash
if [ ! -x ${LBC_VERSION} ]
  then
    tput setaf 2; echo '${LBC_VERSION} has been set.'
  else
    tput setaf 1;echo '${LBC_VERSION} has NOT been set.'
fi
```

{{% notice info %}}
If the result is <span style="color:red">${LBC_VERSION} has NOT been set.</span>, click [here](/020_prerequisites/k8stools/#set-the-aws-load-balancer-controller-version) for the instructions.
{{% /notice %}}

```bash
helm repo add eks https://aws.github.io/eks-charts

export VPC_ID=$(aws eks describe-cluster \
                --name eksworkshop-eksctl \
                --query "cluster.resourcesVpcConfig.vpcId" \
                --output text)

helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eksworkshop-eksctl \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.tag="${LBC_VERSION}" \
    --set region=${AWS_REGION} \
    --set vpcId=${VPC_ID}
```

You can check if the `deployment` has completed

```bash
kubectl -n kube-system rollout status deployment aws-load-balancer-controller
```

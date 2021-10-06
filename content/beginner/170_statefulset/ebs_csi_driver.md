---
title: "Amazon EBS CSI Driver"

date: 2020-02-23T13:57:00-08:00
weight: 4
---
## About Container Storage Interface (CSI)

[The Container Storage Interface](https://github.com/container-storage-interface/spec/blob/master/spec.md) (CSI) is a standard for exposing arbitrary block and file storage systems to containerized workloads on Container Orchestration Systems (COs) like Kubernetes.

By using CSI, third-party storage providers can write and deploy plugins exposing new storage systems in Kubernetes without ever having to touch the core Kubernetes code.

## About the Amazon EBS CSI Driver

The [Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) provides a CSI interface that allows Amazon Elastic Kubernetes Service (Amazon EKS) clusters to manage the lifecycle of Amazon EBS volumes for persistent volumes.

This topic shows you how to deploy the Amazon EBS CSI Driver to your Amazon EKS cluster and verify that it works.

## Configure IAM Policy

The CSI driver is deployed as a set of Kubernetes Pods. These Pods must have permission to perform EBS API operations, such as creating and deleting volumes, and attaching volumes to the EC2 worker nodes that comprise the cluster.

First, let's download the policy JSON document, and create an IAM Policy from it:

```sh
export EBS_CSI_POLICY_NAME="Amazon_EBS_CSI_Driver"

mkdir ${HOME}/environment/ebs_statefulset
cd ${HOME}/environment/ebs_statefulset

# download the IAM policy document
curl -sSL -o ebs-csi-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json

# Create the IAM policy
aws iam create-policy \
  --region ${AWS_REGION} \
  --policy-name ${EBS_CSI_POLICY_NAME} \
  --policy-document file://${HOME}/environment/ebs_statefulset/ebs-csi-policy.json

# export the policy ARN as a variable
export EBS_CSI_POLICY_ARN=$(aws --region ${AWS_REGION} iam list-policies --query 'Policies[?PolicyName==`'$EBS_CSI_POLICY_NAME'`].Arn' --output text)
```

## Configure IAM Role for Service Account

You can associate an IAM role with a Kubernetes service account. This service account can then provide AWS permissions to the containers in any pod that uses that service account. With this feature, you no longer need to provide extended permissions to the Amazon EKS node IAM role so that pods on that node can call AWS APIs.

We'll ask `eksctl` to create an IAM Role that contains the IAM Policy we just created, and associate it with a Kubernetes Service Account called `ebs-csi-controller-irsa` that will be used by the CSI Driver:

```sh
# Create an IAM OIDC provider for your cluster
eksctl utils associate-iam-oidc-provider \
  --region=$AWS_REGION \
  --cluster=eksworkshop-eksctl \
  --approve

# Create a service account
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --name ebs-csi-controller-irsa \
  --namespace kube-system \
  --attach-policy-arn $EBS_CSI_POLICY_ARN \
  --override-existing-serviceaccounts \
  --approve
```

## Deploy the Amazon EBS CSI Driver

Finally, we can deploy the driver using helm.

{{% notice note %}}
If Helm is not installed, [click here the instruction](/beginner/060_helm/helm_intro/install/)
{{% /notice %}}

```sh
# add the aws-ebs-csi-driver as a helm repo
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

# search for the driver
helm search  repo aws-ebs-csi-driver
```

output
{{< output >}}
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
aws-ebs-csi-driver/aws-ebs-csi-driver   2.0.2           1.1.3           A Helm chart for AWS EBS CSI Driver
{{< /output >}}

```sh
helm upgrade --install aws-ebs-csi-driver \
  --version=1.2.4 \
  --namespace kube-system \
  --set serviceAccount.controller.create=false \
  --set serviceAccount.snapshot.create=false \
  --set enableVolumeScheduling=true \
  --set enableVolumeResizing=true \
  --set enableVolumeSnapshot=true \
  --set serviceAccount.snapshot.name=ebs-csi-controller-irsa \
  --set serviceAccount.controller.name=ebs-csi-controller-irsa \
  aws-ebs-csi-driver/aws-ebs-csi-driver

kubectl -n kube-system rollout status deployment ebs-csi-controller
```

Output

{{< output >}}
Waiting for deployment "ebs-csi-controller" rollout to finish: 0 of 2 updated replicas are available...
Waiting for deployment "ebs-csi-controller" rollout to finish: 1 of 2 updated replicas are available...
deployment "ebs-csi-controller" successfully rolled out
{{< /output >}}

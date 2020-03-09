---
title: "Amazon EBS CSI Driver"

date: 2020-02-23T13:57:00-08:00
weight: 4
---

## About the Amazon EBS CSI Driver

On Amazon EKS, the open-source [EBS Container Storage Interface (CSI)
driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) is used to manage
the attachment of Amazon EBS block storage volumes to Kubernetes Pods.

## Configure IAM Policy

The CSI driver is deployed as set of Kubernetes Pods. These Pods must have
permission to perform EBS API operations, such as creating and deleting volumes,
and attaching volumes to the EC2 worker nodes that comprise the cluster.

First, let's download the policy JSON document, and create an IAM Policy from it:

```sh
mkdir ~/environment/ebs_csi_driver
cd ~/environment/ebs_csi_driver
curl -sSL -o ebs-cni-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.4.0/docs/example-iam-policy.json

export EBS_CNI_POLICY_NAME="Amazon_EBS_CSI_Driver"

aws iam create-policy \
  --region ${AWS_REGION} \
  --policy-name ${EBS_CNI_POLICY_NAME} \
  --policy-document file://ebs-cni-policy.json

export EBS_CNI_POLICY_ARN=$(aws --region ${AWS_REGION} iam list-policies --query 'Policies[?PolicyName==`'$EBS_CNI_POLICY_NAME'`].Arn' --output text)
```

## Configure IAM Role for Service Account

Next, we'll ask `eksctl` to create an IAM Role that contains the IAM Policy we
created, and associate it with a Kubernetes Service Account called
`ebs-csi-controller-irsa` that will be used by the CSI Driver:

```sh
eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster=eksworkshop-eksctl --approve

eksctl create iamserviceaccount --cluster eksworkshop-eksctl \
  --name ebs-csi-controller-irsa \
  --namespace kube-system \
  --attach-policy-arn $EBS_CNI_POLICY_ARN \
  --override-existing-serviceaccounts \
  --approve
```

## Deploy EBS CSI Driver

Finally, we can deploy the driver.

First, we'll need to download a few files.  Run:

```sh
cd ~/environment/ebs_csi_driver
for file in kustomization.yml deployment.yml attacher-binding.yml provisioner-binding.yml; do
  curl -sSLO https://raw.githubusercontent.com/aws-samples/eks-workshop/master/content/beginner/170_statefulset/ebs_csi_driver.files/$file
done
```

To complete the deployment:

```sh
kubectl apply -k ~/environment/ebs_csi_driver
```

{{< output >}}
serviceaccount/ebs-csi-controller-sa created
clusterrole.rbac.authorization.k8s.io/ebs-external-attacher-role created
clusterrole.rbac.authorization.k8s.io/ebs-external-provisioner-role created
clusterrolebinding.rbac.authorization.k8s.io/ebs-csi-attacher-binding created
clusterrolebinding.rbac.authorization.k8s.io/ebs-csi-provisioner-binding created
deployment.apps/ebs-csi-controller created
daemonset.apps/ebs-csi-node created
csidriver.storage.k8s.io/ebs.csi.aws.com created
{{< /output >}}

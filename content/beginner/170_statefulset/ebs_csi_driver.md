---
title: "Amazon EBS CSI Driver"

date: 2020-01-25T16:18:56-05:00
weight: 4
---
#### Install Amazon EBS CSI Driver
On [September 10th 2019](https://aws.amazon.com/blogs/opensource/eks-support-ebs-csi-driver/), Amazon announced [EKS support for the EBS Container Storage Interface driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver), an initiative to create unified storage interfaces between container orchestrators such as Kubernetes and storage vendors like AWS.

To deploy the `Amazon EBS CSI Driver` to an Amazon EKS cluster, we need to create an IAM policy called `Amazon_EBS_CSI_Driver` for your worker node instance profile.
```sh
curl -s -O https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.4.0/docs/example-iam-policy.json

export EBS_CNI_POLICY_NAME="Amazon_EBS_CSI_Driver"

aws iam create-policy \
  --region ${AWS_REGION} \
  --policy-name ${EBS_CNI_POLICY_NAME} \
  --policy-document file://example-iam-policy.json

export EBS_CNI_POLICY_ARN=$(aws --region ${AWS_REGION} iam list-policies --query 'Policies[?PolicyName==`'$EBS_CNI_POLICY_NAME'`].Arn' --output text)
```

We will need to ensure the Role Name used by our workers is set in our environment.
```sh
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set
```

If you receive an error or an empty response, please review the [Test the Cluster](/030_eksctl/test/) section

We can now attach the new `Amazon_EBS_CSI_Driver` IAM policy to the worker nodes IAM role.
```sh
aws iam attach-role-policy \
  --region ${AWS_REGION} \
  --policy-arn ${EBS_CNI_POLICY_ARN} \
  --role-name ${ROLE_NAME}
```
Run the command below to verify the policy has been attached to the worker nodes IAM role.
```sh
aws iam list-attached-role-policies \
  --region ${AWS_REGION} \
  --role-name ${ROLE_NAME} | grep '"PolicyName": "Amazon_EBS_CSI_Driver"'
```

The output should look like this.
{{< output >}}
    "PolicyName": "Amazon_EBS_CSI_Driver",
{{< /output >}}

Finally, we can deploy the driver.
```sh
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
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
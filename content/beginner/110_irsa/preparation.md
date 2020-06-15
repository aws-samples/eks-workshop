---
title: "Preparation"
date: 2018-11-13T16:36:24+09:00
weight: 10
draft: false
---

### Enabling IAM Roles for Service Accounts on your Cluster

* The IAM roles for service accounts feature is available on new Amazon EKS Kubernetes version 1.14 clusters, and clusters that were updated to versions 1.14 or 1.13 on or after September 3rd, 2019.

```
kubectl version --short
```

| 1.14 | 1.13 |
| ---- | ---- |
| Client Version: v1.14.6-eks-5047ed | Client Version: v1.13.7 |
| Server Version: v1.14.6-eks-5047ed | Server Version: v1.13.10-eks-5ac0f1 |

{{% notice info %}}
If your EKS cluster version is lower or not match with above, [updating an Amazon EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) in the User Guide
{{% /notice %}}

##### You must use at least version 1.18.15 of the AWS CLI to receive the proper output from this command:

```
aws --version
```

{{< output >}}
aws-cli/1.18.15 Python/2.7.16 Linux/4.14.133-88.112.amzn1.x86_64 botocore/1.12.228
{{< /output >}}

{{% notice info %}}
If your aws cli version is lower than 1.18.15, use [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) in the User Guide
{{% /notice %}}

##### Retrieve OpenID Connect issuer URL:



```
aws eks describe-cluster --name eksworkshop-eksctl --query cluster.identity.oidc.issuer --output text
```
<div data-proofer-ignore>
{{< output >}}
https://oidc.eks.{AWS_REGION}.amazonaws.com/id/D48675832CA65BD10A532F59741CF90B
{{< /output >}}
</div>



---
title: "Preparation"
date: 2018-11-13T16:36:24+09:00
weight: 10
draft: false
---

### Enabling IAM Roles for Service Accounts on your Cluster

* The IAM roles for service accounts feature is available on new Amazon EKS Kubernetes version 1.14 clusters, and clusters that were updated to versions 1.14 or 1.13 on or after September 3rd, 2019.

{{% notice info %}}
If your EKS cluster version is lower or does not match with above, please read the [updating an Amazon EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) section in the User Guide.
{{% /notice %}}

```bash
kubectl version --short
```

Output:
{{< output >}}
Client Version: v1.21.3
Server Version: v1.20.4-eks-6b7464
{{< /output >}}

{{% notice info %}}
If your aws cli version is lower than 1.20.3, use [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) in the User Guide
{{% /notice %}}

```bash
aws --version
```

{{< output >}}
aws-cli/1.20.3 Python/3.7.10 Linux/4.14.225-168.357.amzn2.x86_64 botocore/1.21.3
{{< /output >}}



##### Retrieve OpenID Connect issuer URL:

```bash
aws eks describe-cluster --name eksworkshop-eksctl --query cluster.identity.oidc.issuer --output text
```

<div data-proofer-ignore>
{{< output >}}
https://oidc.eks.us-east-1.amazonaws.com/id/09D1E682ADD23F8431B986E4B2E35BCB
{{< /output >}}

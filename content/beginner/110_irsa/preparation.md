---
title: "Preparation"
date: 2021-07-20T00:00:00-03:00
weight: 10
draft: false
---

### Enabling IAM Roles for Service Accounts on your Cluster

* The IAM roles for service accounts feature is available on new Amazon EKS Kubernetes version 1.16 or higher, and clusters that were updated to versions 1.14 or 1.13 on or after September 3rd, 2019.

{{% notice info %}}
If your EKS cluster version is older than 1.16 your outputs may very. Please consider reading the [updating an Amazon EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) section in the User Guide.
{{% /notice %}}

```bash
kubectl version --short
```

Output:
{{< output >}}
Client Version: v1.20.4-eks-6b7464
Server Version: v1.20.4-eks-6b7464
{{< /output >}}

{{% notice info %}}
If your aws cli version is lower than 1.19.122, use [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) in the User Guide
{{% /notice %}}

```bash
aws --version
```

Output:
{{< output >}}
aws-cli/1.19.112 Python/2.7.18 Linux/4.14.232-177.418.amzn2.x86_64 botocore/1.20.112
{{< /output >}}

### Retrieve OpenID Connect issuer URL

Your EKS cluster has an OpenID Connect issuer URL associated with it, and this will be used when configuring the IAM OIDC Provider. You can check it with:

```bash
aws eks describe-cluster --name eksworkshop-eksctl --query cluster.identity.oidc.issuer --output text
```

Output:
{{< output >}}
https://oidc.eks.us-east-1.amazonaws.com/id/09D1E682ADD23F8431B986E4B2E35BCB
{{< /output >}}

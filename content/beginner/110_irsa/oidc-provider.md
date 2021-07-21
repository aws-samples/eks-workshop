---
title: "Create an OIDC identity provider"
date: 2021-07-20T00:00:00-03:00
weight: 20
draft: false
---

To use IAM roles for service accounts in your cluster, you must create an IAM OIDC Identity Provider. This can be done using the AWS Console, AWS CLIs and `eksctl`. For the sake of this workshop, we will use the last.

##### Check your eksctl version that your eksctl version is at least 0.57.0

```bash
eksctl version
```

{{< output >}}
0.57.0
{{< /output >}}

{{% notice info %}}
If your eksctl version is lower than 0.57.0, use [Installing or Upgrading eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html#installing-eksctl) in the user guide
{{% /notice %}}

##### Create your IAM OIDC Identity Provider for your cluster

```bash
eksctl utils associate-iam-oidc-provider --cluster eksworkshop-eksctl --approve
```

{{< output >}}
2021-07-20 17:51:36 [ℹ]  eksctl version 0.57.0
2021-07-20 17:51:36 [ℹ]  using region us-east-1
2021-07-20 17:51:38 [ℹ]  will create IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "us-east-1"
2021-07-20 17:51:39 [✔]  created IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "us-east-1"
{{< /output >}}

If you go to the [Identity Providers in IAM Console](https://console.aws.amazon.com/iam/home#/providers), you will see OIDC provider has created for your cluster

![OIDC Identity Provider](/images/irsa/irsa-oidc.png)

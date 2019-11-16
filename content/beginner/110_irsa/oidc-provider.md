---
title: "Create an OIDC identity provider"
date: 2018-11-13T16:36:24+09:00
weight: 20
draft: false
---

### To create an IAM OIDC identity provider for your cluster with eksctl

To use IAM roles for service accounts in your cluster, you must create an OIDC identity provider in the IAM console

* Check your eksctl version that your eksctl version is at least 0.5.1

```
eksctl version
```

> [ℹ]  version.Info{BuiltAt:"", GitCommit:"", GitTag:"0.5.3"}

{{% notice info %}}
If your eksctl version is lower than 0.5.1, use [Installing or Upgrading eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html#installing-eksctl) in the user guide
{{% /notice %}}

* Create your OIDC identity provider for your cluster

```
eksctl utils associate-iam-oidc-provider --name eksworkshop-eksctl --approve
```

> [ℹ]  using region {AWS_REGION}<br>[ℹ]  will create IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "{AWS_REGION}"<br>[✔]  created IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "{AWS_REGION}"

If you go to the [Identity Providers in IAM Console](https://console.aws.amazon.com/iam/home#/providers), you will see OIDC provider has created for your cluster

![OIDC Identity Provider](/images/irsa/irsa-oidc.png)

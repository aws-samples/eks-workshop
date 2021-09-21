---
title: "Creating the Jenkins Service Account"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

We'll create a service account for Kubernetes to grant to pods if they need to perform CodeCommit API actions (e.g. GetCommit, ListBranches). This will allow Jenkins to respond to new repositories, branches, and commits.

{{% notice warning %}}
If you have not completed the [IAM Roles for Service Accounts](https://www.eksworkshop.com/beginner/110_irsa/) lab, please complete the [Create an OIDC identity provider](https://www.eksworkshop.com/beginner/110_irsa/oidc-provider/) step now. You do not need to complete any other sections of that lab.
{{% /notice %}}

```bash
eksctl create iamserviceaccount \
    --name jenkins \
    --namespace default \
    --cluster eksworkshop-eksctl \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSCodeCommitPowerUser \
    --approve \
    --override-existing-serviceaccounts
```

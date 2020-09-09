---
title: "Creating the Jenkins Service Account"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

We'll create a service account for Kubernetes to grant to pods if they need to perform CodeCommit API actions (e.g. GetCommit, ListBranches). This will allow Jenkins to respond to new repositories, branches, and commits.

```
eksctl create iamserviceaccount --name jenkins --namespace default --cluster eksworkshop-eksctl --attach-policy-arn arn:aws:iam::aws:policy/AWSCodeCommitPowerUser --approve --override-existing-serviceaccounts
```
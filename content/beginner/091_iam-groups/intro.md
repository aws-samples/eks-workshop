---
title: "Kubernetes Authentication"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 10
---

In the [intro to RBAC](/beginner/090_rbac/) module, we have seen how we can give access to individual users to Kubernetes.

If you have different teams which needs different kind of cluster access, it would be difficult to manually add or remove access for each EKS clusters you want them to give or remove access from.

We can leverage on AWS [IAM Groups](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html) to easily add or remove users and give them permission to whole cluster, or just part of it depending on which groups they belong to.

In this lesson, we will create 3 IAM roles that we will map to 3 IAM groups.

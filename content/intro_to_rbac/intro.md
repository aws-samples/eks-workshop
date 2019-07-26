---
title: "What is RBAC?"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 10
---

According to [the official kubernetes docs:](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

> Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise.


### Objectives for this module
In this module, we're going to explore k8s RBAC by creating an IAM user called rbac-user who is authenticated to access the EKS cluster but is only authorized (via RBAC) to list, get, and watch pods and deployments.

To achieve this, we'll create an IAM user, map that user to a kubernetes role, then perform kubernetes actions under that user's context.

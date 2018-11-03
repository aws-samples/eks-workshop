---
title: "Create the EKS Service Role"
date: 2018-08-07T08:30:11-07:00
weight: 10
draft: false
---

A service-linked role is a unique type of IAM role that is linked directly to
an AWS service. Service-linked roles are predefined by the service and include
all the permissions that the service requires to call other AWS services on your behalf.

To create your Amazon EKS service role in the IAM console:

1. Open the IAM console at https://console.aws.amazon.com/iam/

2. Choose `Roles`, then `Create role`

3. Choose `EKS` from the list of services, then `Allows Amazon EKS to manage your clusters on your behalf` for your use case, then `Next: Permissions`

Choose `Next: Review`

For Role name, enter a unique name for your role, such as `EKSServiceRole`, then choose `Create role`
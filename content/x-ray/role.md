---
title: "Modify IAM Role"
date: 2018-11-177T08:30:11-07:00
weight: 10
draft: false
---

In order for the [X-Ray daemon](https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon.html) to communicate with the service, we need to add a policy to the worker nodes' [AWS Identity and Access Management](https://aws.amazon.com/iam/) (IAM) role.

Modify the role in the Cloud9 terminal:

```
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess
```

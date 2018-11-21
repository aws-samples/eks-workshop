---
title: "Modify IAM Role"
date: 2018-11-177T08:30:11-07:00
weight: 10
draft: false
---

In order for the [X-Ray daemon](https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon.html) to communicate with the service, we need to add a policy to the worker nodes' [AWS Identity and Access Management](https://aws.amazon.com/iam/) (IAM) role.

Modify the role in the Cloud9 terminal:

```
PROFILE=$(aws ec2 describe-instances --filters --filters Name=tag:Name,Values=eksworkshop-eksctl-0-Node --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text | cut -d '/' -f 2)

ROLE=$(aws iam get-instance-profile --instance-profile-name $PROFILE --query "InstanceProfile.Roles[0].RoleName" --output text)

aws iam attach-role-policy --role-name $ROLE --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess
```

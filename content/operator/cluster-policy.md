---
title: "Configure Instance Role Policy"
date: 2018-08-07T08:30:11-07:00
weight: 5
draft: true
---

To deploy the AWS Service Operator you'll first need to configure the nodes
instance policy. Being pre-release this requires `AdministratorAccess`. This
will be changed overtime to reflect it's true needs.

```
INSTANCE_ROLE_ARN=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 --output text --query Stacks[0].Outputs[0].OutputValue | sed -e 's/.*\///g')

aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --role-name ${INSTANCE_ROLE_ARN}
```

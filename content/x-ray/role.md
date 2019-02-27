---
title: "Modify IAM Role"
date: 2018-11-177T08:30:11-07:00
weight: 10
draft: false
---

In order for the [X-Ray daemon](https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon.html) to communicate with the service, we need to add a policy to the worker nodes' [AWS Identity and Access Management](https://aws.amazon.com/iam/) (IAM) role.

Modify the role in the Cloud9 terminal:

{{%expand "Expand here if you need to export the Role Name" %}}

```bash
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks | jq -r .Stacks[].StackName | grep eksctl-eksworkshop-eksctl-nodegroup)
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile
```

{{% /expand %}}

```
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess
```

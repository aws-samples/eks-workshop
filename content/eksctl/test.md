---
title: "Test the Cluster"
date: 2018-08-07T13:36:57-07:00
weight: 30
---

Confirm your Nodes:

```bash
kubectl get nodes
```

Export the Worker Role Name for use throughout the workshop

```bash
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks | jq -r '.Stacks[].StackName' | grep eksctl-eksworkshop-eksctl-nodegroup)
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile

```

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!

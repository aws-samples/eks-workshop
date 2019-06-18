---
title: "Test the Cluster"
date: 2018-08-07T13:36:57-07:00
weight: 30
---

#### Configure IAM authentication for the cluster:
You will likely see an error in the output similar to this:
```
[✖]  neither aws-iam-authenticator nor heptio-authenticator-aws are installed
[ℹ]  cluster should be functional despite missing (or misconfigured) client binaries
[✔]  EKS cluster "eksworkshop-eksctl" in "us-east-2" region is ready
```

This is caused by eksctl wanting to use aws-iam-authencator to pull IAM tokens.
As of aws-cli version 1.16.156, this token functionality is built in. Let's check
our aws-cli version:
```
aws --version # in Cloud9, the version output should already be higher than 1.16.156
```

Your Cloud9 workspace should already have a version late enough to pull IAM tokens.

If you need to update the aws-cli, use this command:
```
pip install awscli --upgrade --user # this updates aws-cli to the latest available version for the user

aws --version
```

We can update our kubectl config file to use the aws-cli for pulling IAM tokens with
this command:
```
aws eks update-kubeconfig --name eksworkshop-eksctl # this updates kubeconfig to pull iam tokens using aws-cli
```

#### Test the cluster:
Confirm your Nodes:

```bash
kubectl get nodes # if we see our 3 nodes, we know we have authenticated correctly
```

Export the Worker Role Name for use throughout the workshop

```bash
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep nodegroup)
INSTANCE_PROFILE_ARN=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Arn')
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile
echo "export INSTANCE_PROFILE_ARN=${INSTANCE_PROFILE_ARN}" >> ~/.bash_profile

```

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!

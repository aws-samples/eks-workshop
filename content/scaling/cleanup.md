---
title: "Cleanup Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

Replace the first variable with the Cloudformation stack name of your EKS cluster :

```
CFN_EKS_STACK_NAME=eksctl-eksworkshop-eksctl-nodegroup-<ID_TO_REPLACE>
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name $CFN_EKS_STACK_NAME | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
kubectl delete -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
kubectl delete -f ~/environment/cluster-autoscaler/nginx.yaml
rm -rf ~/environment/cluster-autoscaler
aws iam delete-role-policy --role-name $ROLE_NAME --policy-name ASG-Policy-For-Worker
kubectl delete hpa,svc php-apache
kubectl delete deployment php-apache load-generator
```

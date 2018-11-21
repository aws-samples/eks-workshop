---
title: "Cleanup Logging"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

```
cd ~/environment
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
kubectl delete -f ~/environment/fluentd/fluentd.yml
rm -rf ~/environment/fluentd/
aws es delete-elasticsearch-domain --domain-name kubernetes-logs
aws logs delete-log-group --log-group-name /eks/eksworkshop-eksctl/containers
aws iam delete-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker
aws iam detach-role-policy --role-name lambda_basic_execution --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name lambda_basic_execution
rm -rf ~/environment/iam_policy/
```

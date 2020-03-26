---
title: "Test the Cluster"
date: 2018-08-07T13:36:57-07:00
weight: 30
---
#### Test the cluster:
Confirm your nodes:

```bash
kubectl get nodes # if we see our 3 nodes, we know we have authenticated correctly
```

#### Export the Worker Role Name for use throughout the workshop:

```bash
STACK_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile
```

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!

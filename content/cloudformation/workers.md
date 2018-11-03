---
title: "Add EC2 Workers - On-Demand and Spot"
date: 2018-08-07T11:05:19-07:00
weight: 60
draft: false
---

### TODO: Code here to highlight the spot node labels Note: Create at least 2 separate ASG's like in blog.


Now that your VPC and Kubernetes control plane are created, you can launch and
configure your worker nodes. We will now use CloudFormation to launch worker
nodes that will connect to the EKS cluster:

First, make export our network information
```
export SECURITY_GROUP=$(aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue" --output text)
export SUBNET_IDS=$( aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue" --output text)
export VPC_ID=$(aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" --output text)
```


Let’s confirm the variables are now set in our environment:
```
echo VPC_ID=${VPC_ID}
echo SECURITY_GROUP=${SECURITY_GROUP}
echo SUBNET_IDS=${SUBNET_IDS}
```
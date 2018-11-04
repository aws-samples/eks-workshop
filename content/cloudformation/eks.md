---
title: "Create the EKS Cluster"
date: 2018-08-07T09:42:43-07:00
weight: 40
draft: false
---

To build the EKS cluster, we need to tell the EKS service which IAM Service role
to use, and which Subnets and Security Group to use. We can gather this information
from our previous labs where we built the IAM role and VPC:
{{% notice info %}}
If you named your IAM role or CloudFormation stack something different, you will need to edit the commands below with the correct values.
{{% /notice %}}
```
export SERVICE_ROLE=$(aws iam get-role --role-name "EKSServiceRole" --query Role.Arn --output text)

export SECURITY_GROUP=$(aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue" --output text)

export SUBNET_IDS=$( aws cloudformation describe-stacks --stack-name "eksworkshop-vpc" --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue" --output text)
```

Let's confirm the variables are now set in our environment:
```
echo SERVICE_ROLE=${SERVICE_ROLE}
echo SECURITY_GROUP=${SECURITY_GROUP}
echo SUBNET_IDS=${SUBNET_IDS}
```

Now we can create the EKS cluster:
```
aws eks create-cluster --name eksworkshop --role-arn "${SERVICE_ROLE}" --resources-vpc-config subnetIds="${SUBNET_IDS}",securityGroupIds="${SECURITY_GROUP}"
```
{{% notice info %}}
Cluster provisioning usually takes less than 10 minutes.
{{% /notice %}}

You can query the status of your cluster with the following command:
```
aws eks describe-cluster --name "eksworkshop" --query cluster.status --output text
```

When your cluster status is **ACTIVE** you can proceed.

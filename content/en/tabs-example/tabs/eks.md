---
title: "Embedded tab content"
disableToc: true
hidden: true
---

To build the EKS cluster, we need to tell the EKS service which IAM Service role
to use, and which Subnets and Security Group to use. We can gather this information
from our previous labs where we built the IAM role and VPC:

```
export SERVICE_ROLE=$(aws iam get-role --role-name "eks-service-role-workshop" --query Role.Arn --output text)

export SECURITY_GROUP=$(aws cloudformation describe-stacks --stack-name "eksworkshop-cf" --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue" --output text)

export SUBNET_IDS=$( aws cloudformation describe-stacks --stack-name "eksworkshop-cf" --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue" --output text)
```

Let's confirm the variables are now set in our environment:
```
echo SERVICE_ROLE=${SERVICE_ROLE}
echo SECURITY_GROUP=${SECURITY_GROUP}
echo SUBNET_IDS=${SUBNET_IDS}
```

Now we can create the EKS cluster:
```
aws eks create-cluster --name eksworkshop-cf --role-arn "${SERVICE_ROLE}" --resources-vpc-config subnetIds="${SUBNET_IDS}",securityGroupIds="${SECURITY_GROUP}"
```
{{% notice info %}}
Cluster provisioning usually takes less than 10 minutes.
{{% /notice %}}

You can query the status of your cluster with the following command:
```
aws eks describe-cluster --name "eksworkshop-cf" --query cluster.status --output text
```

When your cluster status is **ACTIVE** you can proceed.

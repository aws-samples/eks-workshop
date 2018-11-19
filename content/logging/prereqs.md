---
title: "Configure IAM Policy for Worker Nodes"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

We will be deploying Fluentd as a DaemonSet, or one pod per worker node. The fluentd log daemon will collect logs and forward to CloudWatch Logs. This will require the nodes to have permissions to send logs and create log groups and log streams. This can be accomplished with an IAM user, IAM role, or by using a tool like `Kube2IAM`.

In our example, we will create an IAM policy and attach it the the Worker node role.

Collect the Instance Profile and Role NAME from the CloudFormation Stack
```
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
```
Create a new IAM Policy and attach it to the Worker Node Role.
```
mkdir ~/environment/iam_policy
cat <<EoF > ~/environment/iam_policy/k8s-logs-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EoF
aws iam put-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker --policy-document file://~/environment/iam_policy/k8s-logs-policy.json
```

Validate that the policy is attached to the role
```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker
```

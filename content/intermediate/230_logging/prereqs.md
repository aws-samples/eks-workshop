---
title: "Configure IAM Policy for Worker Nodes"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

We will be deploying Fluentd as a DaemonSet, or one pod per worker node. The fluentd log daemon will collect logs and forward to CloudWatch Logs. This will require the nodes to have permissions to send logs and create log groups and log streams. This can be accomplished with an IAM user, IAM role, or by using a tool like `Kube2IAM`.

In our example, we will create an IAM policy and attach it the the Worker node role.

First, we will need to ensure the Role Name our workers use is set in our environment:

```bash
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set
```

If you receive an error or empty response, expand the steps below to export.

{{%expand "Expand here if you need to export the Role Name" %}}
If `ROLE_NAME` is not set, please review: [/030_eksctl/test/](/030_eksctl/test/)
{{% /expand %}}

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

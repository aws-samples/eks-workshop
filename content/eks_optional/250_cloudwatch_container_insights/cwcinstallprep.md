---
title: "Preparing to Install Container Insights"
chapter: false
weight: 4
---

{{% notice info %}}
The full documentation for CloudWatch Container Insights can be found [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html).
{{% /notice %}}

#### Add the necessary policy to the IAM role for your worker nodes

In order for `CloudWatch` to get the necessary monitoring info, we need to install the CloudWatch Agent to our EKS Cluster.

First, we will need to ensure the Role Name our workers use is set in our environment:

```bash
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set
```

{{% notice warning %}}
If `ROLE_NAME` is not set, please review the [test the cluster section](/030_eksctl/test/).
{{% /notice %}}

We will attach the policy to the nodes IAM Role:

```bash
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
```

Finally, let's verify that the policy has been attached to the IAM ROLE:

```bash
aws iam list-attached-role-policies --role-name $ROLE_NAME | grep CloudWatchAgentServerPolicy || echo 'Policy not found'
```

Output
{{< output >}}
"PolicyName": "CloudWatchAgentServerPolicy",
"PolicyArn": "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
{{< /output >}}

Now we can proceed to the actual install of the CloudWatch Insights.

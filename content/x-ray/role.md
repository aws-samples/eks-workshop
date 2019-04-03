---
title: "Modify IAM Role"
date: 2018-11-177T08:30:11-07:00
weight: 10
draft: false
---

In order for the [X-Ray daemon](https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon.html) 
to communicate with the service, we need to add a policy to the worker nodes' 
[AWS Identity and Access Management](https://aws.amazon.com/iam/) (IAM) role.

First, we will need to ensure the Role Name our workers use is set in our environment:

```bash
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set
```

{{%expand "Expand here if you need to export the Role Name" %}}
If `ROLE_NAME` is not set, please review: [/eksctl/test/](/eksctl/test/)
{{% /expand %}}

```text
# Example Output
ROLE_NAME is eks-workshop-nodegroup
```

{{< tabs name="Attach IAM Policy to the Role" >}}
{{{< tab name="Workshop at AWS event" >}}
This IAM policy has been attached to the correct role for you.<br>

You can proceed with the next step.
{{< /tab >}}
{{< tab name="Workshop in your own account" codelang="bash" >}}
aws iam attach-role-policy --role-name $ROLE_NAME \
--policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess
{{< /tab >}}}
{{< /tabs >}}



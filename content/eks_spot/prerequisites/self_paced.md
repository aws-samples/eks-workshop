---
title: "...on your own"
chapter: false
weight: 10
---

{{% notice warning %}}
Only complete this section if you are running the workshop on your own. If you are at an AWS hosted event (such as re:Invent, Kubecon, Immersion Day, etc), go to [Start the workshop at an AWS event]({{< relref "aws_event.md" >}}).
{{% /notice %}}

### Running the workshop on your own

{{% notice warning %}}
Your account must have the ability to create new IAM roles and scope other IAM permissions.
{{% /notice %}}

1. If you don't already have an AWS account with Administrator access: [create
one now by clicking here](https://aws.amazon.com/getting-started/)

1. Once you have an AWS account, ensure you are following the remaining workshop steps
as an IAM user with administrator access to the AWS account:
[Create a new IAM user to use for the workshop](https://console.aws.amazon.com/iam/home?#/users$new)

1. Enter the user details:
![Create User](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-1-create-user.png)

1. Attach the AdministratorAccess IAM Policy:
![Attach Policy](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-2-attach-policy.png)

1. Click to create the new user:
![Confirm User](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-3-create-user.png)

1. Take note of the login URL and save:
![Login URL](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-4-save-url.png)


Once you have completed the step above, **you can head straight to [Create a Workspace]({{<  relref "workspace.md"  >}})**
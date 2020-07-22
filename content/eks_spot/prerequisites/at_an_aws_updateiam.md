---
title: "...AT AN AWS EVENT - Updating Workspace Cloud9 Instance"
chapter: false
disableToc: true
hidden: true
---

## Attach the IAM role to your Workspace

1. Follow [this deep link to find your Cloud9 EC2 instance](https://console.aws.amazon.com/ec2/v2/home?#Instances:tag:Name=aws-cloud9-.*workshop.*;sort=desc:launchTime)
1. Select the instance, then choose **Actions / Instance Settings / Attach/Replace IAM Role**
![c9instancerole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9instancerole.png)
1. Choose **TeamRoleInstance** from the **IAM Role** drop down, and select **Apply**
![c9attachrole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9attachroleee.png)

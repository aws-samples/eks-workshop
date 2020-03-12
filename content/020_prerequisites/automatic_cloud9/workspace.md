---
title: "Create a Workspace"
chapter: false
weight: 14
---

{{% notice warning %}}
The Cloud9 workspace should be built by an IAM user with Administrator privileges,
not the root account user. Please ensure you are logged in as an IAM user, not the root
account user.
{{% /notice %}}

{{% notice tip %}}
Ad blockers, javascript disablers, and tracking blockers should be disabled for
the cloud9 domain, or connecting to the workspace might be impacted.
Cloud9 requires third-party-cookies. You can whitelist the [specific domains]( https://docs.aws.amazon.com/cloud9/latest/user-guide/troubleshooting.html#troubleshooting-env-loading).
{{% /notice %}}

### Launch Cloud9 in your closest region:
| Launch template |  |  |
| ------ |:------:|:--------:|
| Oregon (us-west-2) |  {{< c9-launch "cloud9-autodeploy.cfn.yml" "eksworkshop-cloud9" "us-west-2" >}} | {{< cf-download "cloud9-autodeploy.cfn.yml" >}}  |
| Ireland (eu-west-1) |  {{< c9-launch "cloud9-autodeploy.cfn.yml" "eksworkshop-cloud9" "eu-west-1" >}} | {{< cf-download "cloud9-autodeploy.cfn.yml" >}}  |
| Ohio (us-east-2) |  {{< c9-launch "cloud9-autodeploy.cfn.yml" "eksworkshop-cloud9" "us-east-2" >}} | {{< cf-download "cloud9-autodeploy.cfn.yml" >}}  |
| Singapore (ap-southeast-1) |  {{< c9-launch "cloud9-autodeploy.cfn.yml" "eksworkshop-cloud9" "ap-southeast-1" >}} | {{< cf-download "cloud9-autodeploy.cfn.yml" >}}  |

On the Cloudformation Parametes page leave everything on default and click **next**
![c9_cfn_stack_parameters](/images/c9_cfn_stack_parameters.png)

On the next page, just click **next**

On the bottom of the last page, be sure to tick the checkbox like shown below and click **Create Stack**
![c9_cfn_iamrolepermission](/images/c9_cfn_iamrolepermission.png)

When you clicked **Create Stack** your Cloud9 Environment will be setup automatically for you. Grap a coffee and continue with the next section. 

{{% notice info %}}
The Deployment and Bootstrapping of the Cloud9 Environment will take about 10-15 minutes. 
{{% /notice %}}

Visit your [Cloud9 Environment] (https://console.aws.amazon.com/cloud9/home?#)

When it came up, customize the environment by closing the **welcome tab**
and **lower work area**, and opening a new **terminal** tab in the main work area:
![c9before](/images/c9before.png)

- Your workspace should now look like this:
![c9after](/images/c9after.png)

- If you like this theme, you can choose it yourself by selecting **View / Themes / Solarized / Solarized Dark**
in the Cloud9 workspace menu.


The Cloud9 Environment has been setup and bootstrapped. You should find the following tools installed:

- aws cli
- kubectl 
- eksctl 
- an SSH Key imported into your AWS Account as a [Key Pair] (https://console.aws.amazon.com/ec2/v2/home?#KeyPairs:) named **'eksworkshop'**

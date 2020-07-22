---
title: "Create a Workspace"
chapter: false
weight: 30
---

{{% notice warning %}}
If you are running the workshop on your own, the Cloud9 workspace should be built by an IAM user with Administrator privileges, not the root account user. Please ensure you are logged in as an IAM user, not the root
account user.
{{% /notice %}}

{{% notice info %}}
If you are at an AWS hosted event (such as re:Invent, Kubecon, Immersion Day, or any other event hosted by 
an AWS employee) follow the instructions on the region that should be used to launch resources
{{% /notice %}}

{{% notice tip %}}
Ad blockers, javascript disablers, and tracking blockers should be disabled for
the cloud9 domain, or connecting to the workspace might be impacted.
Cloud9 requires third-party-cookies. You can whitelist the [specific domains]( https://docs.aws.amazon.com/cloud9/latest/user-guide/troubleshooting.html#troubleshooting-env-loading).
{{% /notice %}}

### Launch Cloud9 in your closest region:

{{< tabs name="Region" >}}
    {{< tab name="Oregon" include="us-west-2.md" />}}
    {{< tab name="Ireland" include="eu-west-1.md" />}}
    {{< tab name="Ohio" include="us-east-2.md" />}}
    {{< tab name="Singapore" include="ap-southeast-1.md" />}}
{{< /tabs >}}

- Select **Create environment**
- Name it **eksworkshop**, and take all other defaults
- When it comes up, customize the environment by closing the **welcome tab**
and **lower work area**, and opening a new **terminal** tab in the main work area:
![c9before](/images/using_ec2_spot_instances_with_eks/prerequisites/c9before.png)

- Your workspace should now look like this:
![c9after](/images/using_ec2_spot_instances_with_eks/prerequisites/c9after.png)

- If you like this theme, you can choose it yourself by selecting **View / Themes / Solarized / Solarized Dark**
in the Cloud9 workspace menu.

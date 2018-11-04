---
title: "Create a Workspace"
chapter: false
weight: 10
draft: false
---

{{% notice warning %}}
The Cloud9 workspace should be built by an IAM user with Administrator privileges,
not the root account user. Please ensure you are logged in as an IAM user, not the root
account user.
{{% /notice %}}


{{% notice info %}}
This workshop was designed to run in the **Dublin Ireland (eu-west-1)** region for re:Invent.
{{% /notice %}}


{{% notice tip %}}
Ad blockers, javascript disablers, and tracking blockers should be disabled for
the cloud9 domain, or connecting to the workspace might be impacted. Some users have also reported compatibility issues with Safari. **Please use Chrome or Firefox**
{{% /notice %}}

- Create a [Cloud9 Environment](https://eu-west-1.console.aws.amazon.com/cloud9/home?region=eu-west-1)
  - select **Create environment**
- Name it **eksworkshop**, and take all other defaults
- When it comes up, customize the environment by closing the **welcome tab**
and **lower work area**, and opening a new **terminal** tab in the main work area:
![c9before](/images/c9before.png)

- Your workspace should now look like this:
![c9after](/images/c9after.png)

- If you like this theme, you can choose it yourself by selecting **View / Themes / Solarized / Solarized Dark**
in the Cloud9 workspace menu.

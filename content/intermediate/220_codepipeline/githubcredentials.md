---
title: "GitHub Access Token"
date: 2018-10-087T08:30:11-07:00
weight: 13
draft: false
---

In order for CodePipeline to receive callbacks from GitHub, we need to generate a personal access token.

Once created, an access token can be stored in a secure enclave and reused, so this step is only required
during the first run or when you need to generate new keys.

Open up the [New personal access page](https://github.com/settings/tokens/new) in GitHub.

{{% notice info %}}
You may be prompted to enter your GitHub password
{{% /notice %}}

Enter a value for **Token description**, check the **repo** permission scope and scroll down and click the **Generate token** button

![Generate New](/images/codepipeline/github_token_name.png)

Copy the **personal access token** and save it in a secure place for the next step

![Generate New](/images/codepipeline/github_copy_access.png)

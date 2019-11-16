---
title: "GitHub Setup"
date: 2018-10-087T08:30:11-07:00
weight: 10
draft: false
---

We are going to create 2 GitHub repositories.  One will be used for a sample application that will trigger a Docker image build.  Another will be used to hold Kubernetes manifests that Weave Flux deploys into the cluster.  Note this is a pull based method compared to other continuous deployment tools that push to Kubernetes.  

Create the sample application repository by clicking [here](https://github.com/new).  

Fill in the form with repository name, description, and check initializing the repository with a README as shown below and click **Create repository**.

![Create Sample App Repository](/images/weave_flux/github_create_sample_app.png)

Repeat this process to create the Kubernetes manifests repositories by clicking [here](https://github.com/new).  Fill in the form as shown below and click **Create repository**.  

![Create Kubernetes Manifest Repository](/images/weave_flux/github_create_k8s.png)

The next step is to create a personal access token that will allow CodePipeline to receive callbacks from GitHub.  
Once created, an access token can be stored in a secure enclave and reused, so this step is only required
during the first run or when you need to generate new keys.

Open up the [New personal access page](https://github.com/settings/tokens/new) in GitHub.

{{% notice info %}}
You may be prompted to enter your GitHub password
{{% /notice %}}

Enter a value for **Token description**, check the **repo** permission scope and scroll down and click the **Generate token** button

![Generate New](/images/weave_flux/github_token_name.png)

Copy the **personal access token** and save it in a secure place for the next step

![Generate New](/images/weave_flux/github_copy_access.png)

We will need to revisit GitHub one more time once we provision Weave Flux to enable Weave to control repositories.  However, at this time you can move on.  

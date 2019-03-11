---
title: "Cleanup the Workspace"
chapter: false
weight: 50
---

Since we no longer need the Cloud9 instance to have Administrator access
to our account, we can delete the role we created:

  - Go to [the IAM Console](https://console.aws.amazon.com/iam/home?#/roles/eksworkshop-admin)
  - Click **Delete role** in the upper right corner

Finally, let's delete our Cloud9 EC2 Instance:

- Go to your [Cloud9 Environment](https://console.aws.amazon.com/cloud9/home)
- Select the environment named **eksworkshop** and pick **delete**

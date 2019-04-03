---
title: "AWS Workshop Portal"
chapter: false
weight: 20
---

### Login to AWS Workshop Portal

This workshop creates an AWS acccount and a Cloud9 environment. You will need the **Participant Hash** provided upon entry, and your email address to track your unique session.

Connect to the portal by clicking the button or browsing to [https://portal.awsworkshop.io/](https://portal.awsworkshop.io/).

<a
  href="https://portal.awsworkshop.io/"
target="_blank" class="btn btn-default">
Connect to Portal
<i class="fas fa-sign-in-alt"></i>
</a>

![Portal Login](/images/portal_login.png)

Enter your **Participant Hash** and your email address, and click **Log In**.

Once you have been logged in, please first log into the AWS console by clicking on the <i class="fas fa-terminal"></i> button. Once you have successfully logged into the AWS Console, you can open the Cloud9 IDE by clicking on the <i class="fas fa-desktop"></i> button.

![Portal Buttons](/images/portal_buttons.png)

{{% notice note %}}
The workshop added an IAM role for performing all the steps of the workshop in the Cloud9 Environment. You do not need to add a role to the instance powering the Cloud9 Environment.
{{% /notice %}}

Once you have completed the step above, you can head straight to [**Install Kubernetes Tools**](/prerequisites/k8stools/)

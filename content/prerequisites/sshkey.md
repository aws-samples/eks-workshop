---
title: "Create a SSH key"
chapter: false
weight: 21
---

{{% notice info %}}
Starting from here, when you see command to be entered such as below, you will enter these commands into Cloud9 IDE. You can use the **Copy to clipboard** feature (right hand upper corner) to simply copy and paste into Cloud9. In order to paste, you can use Ctrl + V for Windows or Command + V for Mac.
{{% /notice %}}

Please run this command to generate SSH Key in Cloud9. This key will be used on the worker node instances to allow ssh access if necessary.

```

ssh-keygen

```

{{% notice tip %}}
Press `enter` 3 times to take the default choices
{{% /notice %}}

<!---
removing below because we are only using eksctl now, and it handles the key automatically
1. Upload the public key to your EC2 region:
```
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub
```
-->

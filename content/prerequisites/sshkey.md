---
title: "Create a SSH key"
chapter: false
weight: 21
draft: true
---

```

ssh-keygen

```

{{% notice tip %}}
Press `enter` 3 times to take the default choices
{{% /notice %}}

This key will be used on the worker node instances to allow ssh access if necessary.

Upload the public key to your EC2 region:
```
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub
```
-->

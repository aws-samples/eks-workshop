---
title: "Update to the latest AWS CLI"
chapter: false
weight: 45
draft: true
comment: default install now includes aws-cli/1.15.83
---

{{% notice tip %}}
For this workshop, please ignore warnings about the version of pip being used.
{{% /notice %}}

1. Run the following command to view the current version of aws-cli:
```
aws --version
```

2. Remove v1 version:
```
pip uninstall awscli 
```

3. Upgrade to the latest version:
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
sudo ./aws/install 
```

4. Confirm you have a newer version:
```
aws --version
```

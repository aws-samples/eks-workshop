---
title: "Prerequisites"
date: 2018-08-07T12:50:08-07:00
weight: 10
draft: true
---

For this chapter, we need to download the [Terraform](https://www.terraform.io/) binary:
```
curl -kLo /tmp/terraform.zip "https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip"

sudo unzip -d /usr/local/bin/ /tmp/terraform.zip

sudo chmod +x /usr/local/bin/terraform
```

Let’s make sure we have a working Terraform binary:
```
terraform version
```

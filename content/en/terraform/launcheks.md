---
title: "Launch EKS Cluster"
date: 2018-08-07T13:03:16-07:00
weight: 30
draft: true
---

We start by initializing the Terraform state:
```
terraform init
```

We can now plan our deployment:
```
terraform plan -var 'cluster-name=eksworkshop-tf' -var 'desired-capacity=3' -out eksworkshop-tf
```

And if we want to apply that plan:
```
terraform apply "eksworkshop-tf"
```
{{% notice info %}}
Applying the fresh terraform plan will take approximately 15 minutes
{{% /notice %}}

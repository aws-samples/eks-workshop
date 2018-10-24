---
title: "Embedded tab content"
disableToc: true
hidden: true
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

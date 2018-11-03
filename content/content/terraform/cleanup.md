---
title: "Cleanup"
date: 2018-08-07T13:15:13-07:00
weight: 60
draft: true
---
In order to delete the resources created for this EKS cluster, run the following commands:

View the plan:
```
terraform plan -destroy -out eksworkshop-destroy-tf
```

Execute the plan:
```
terraform apply "eksworkshop-destroy-tf"
```

{{% notice info %}}
Destroying all the resources will take approximately 15 minutes
{{% /notice %}}

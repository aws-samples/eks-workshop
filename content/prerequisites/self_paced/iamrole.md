---
title: "Create an IAM role for your Workspace"
chapter: false
weight: 25
---


1. Follow [this deep link to create an IAM role with Administrator access.](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess)
1. Confirm that **AWS service** and **EC2** are selected, then click **Next** to view permissions.
1. Confirm that **AdministratorAccess** is checked, then click **Next** to review.
1. Enter **eksworkshop-admin** for the Name, and select **Create Role**
![createrole](/images/createrole.png)

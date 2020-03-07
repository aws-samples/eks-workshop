---
title: "Prerequisite"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

{{% notice warning %}}
AWS Fargate with Amazon EKS is currently only available in the following Regions: **us-east-1**, **us-east-2**, **ap-northeast-1**, **eu-west-1**. Pods running on Fargate are supported on EKS clusters beginning with Kubernetes version 1.14 and platform version `eks.5`.
{{% /notice  %}}

Run this command to verify if AWS Fargate with Amazon EKS is available in the Region you choose to deploy your Amazon EKS cluster.

```bash
if [ $AWS_REGION = "us-east-1" ] || [ $AWS_REGION = "us-east-2" ] || [ $AWS_REGION = "ap-northeast-1" ] || [ $AWS_REGION = "eu-west-1" ] ; then
  clear
  echo -e "AWS Fargate with Amazon EKS is \033[0;32mavailable\033[0m in ${AWS_REGION}."
  echo "You can continue this lab."
else
  clear
  echo -e "AWS Fargate with Amazon EKS is \033[0;31mnot yet available\033[0m in ${AWS_REGION}."
  echo "Please deploy deploy your cluster in one of the regions mentionned above"
fi
```

---
title: "Prerequisite"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

AWS Fargate with Amazon EKS is currently only available in the following Regions:

| Region Name | Region |
|---|---|
| US East (Ohio) | us-east-2 |
| US East (N. Virginia) | us-east-1 |
| Asia Pacific (Tokyo) | ap-northeast-1 |
| EU (Ireland) | eu-west-1 |

Run this command to verify if AWS Fargate with Amazon EKS is available in the Region you choose to deploy your Amazon EKS cluster.

```bash
if [ $AWS_REGION = "us-east-1" ] || [ $AWS_REGION = "us-east-2" ] || [ $AWS_REGION = "ap-northeast-1" ] || [ $AWS_REGION = "eu-west-1" ] ; then
  echo -e "\033[0;32mAWS Fargate with Amazon EKS is available in your Region."
  echo "You can continue this lab."
else
  echo -e "\033[0;31mAWS Fargate with Amazon EKS is not yet available in your Region."
  echo "Deploy your cluster in one of the Regions mentioned above"
fi
```

{{% notice warning %}}
Don't continue the lab unless the output is:
*AWS Fargate with Amazon EKS is available in your Region.
You can continue this lab*.
{{% /notice %}}

---
title: "Create AMP workspace"
date: 2021-01-21T21:42:08-05:00
draft: false
weight: 10
---



## Create a new AMP workspace

Go to the [AMP console](https://console.aws.amazon.com/prometheus/) and type-in a name for the AMP workspace and click on `Create`

![Create AMP workspace](/images/amp/amp1.png)

Alternatively, you can also use AWS CLI to create the workspace using the following command:
```
aws amp create-workspace --alias eks-workshop --region us-east-1
```

The AMP workspace should be created in just a few seconds. Once created, you will be able to see the workspace as shown below:

![AMP workspace created](/images/amp/amp3.png)


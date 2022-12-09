---
title: "AWS Marketplace Subscription"
date: 2018-11-13T16:36:24+09:00
weight: 10
draft: false
---

With introduction of Amazon EKS add-on for Tetrate Istio Distro (TID) - there are two ways to deploy istio in EKS Cluster - via `AWS web console` or via `command line`

Before TID is deployed, a FREE AWS Marketplace subscription is required. TID is listed for FREE but the formal subscription is part of the process. Below are the steps to subscribe to the free Tetrate offering:

- Login to your AWS console UI and select `AWS Marketplace > Discover products` and search for `TID`

![Alt text](/images/tetrate-istio-distro/AWS_Marketplace_1.png "Locate TID on AWS Marketplace")

- Read the product description and hit `Continue to subscribe` button

![Alt text](/images/tetrate-istio-distro/AWS_Marketplace_2.png "Subscribe to TID on AWS Marketplace")

- Read the terms and click `Accept Terms` button

![Alt text](/images/tetrate-istio-distro/AWS_Marketplace_3.png "Review and Accept the terms")

- Subscription process can take few moments, please, be patient

![Alt text](/images/tetrate-istio-distro/AWS_Marketplace_4.png "Subscription in progress")

- After few moments - `effective date` changes from `Pending` to today date - proceed with `Continue to configuration` button

![Alt text](/images/tetrate-istio-distro/AWS_Marketplace_5.png "TID is Ready to Configure")

- Now you're presented with the deployment options - both options are available TID deployment using **Helm** or **AWS EKS add-on**. In this tutorial the focus is on `AWS EKS add-on` approach:

![Alt text](/images/tetrate-istio-distro/AWS_Marketplace_6.png "Deployment options")

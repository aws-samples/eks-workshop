---
title: "Create a Free Spot.io Account"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

In this section, you will create a free Spot.io account, and subsequently link that account to your AWS account.
A video tutorial covering this section can be found at the bottom of the page.

#### Creating a Spot.io Account
Begin by heading over to [spot.io](https://spot.io/?utm_campaign=eskworkshop&utm_source=eksworkshop) and clicking the "Get Started for Free" button on the top right. This will take you to the sign up page, where you create a free account. 

You will need to provide the following:

 - Full Name
 - Company
 - Email
 - Country

{{% notice info %}}
If you are running this workshop on your own, you will be able to keep your account, as it is free of charge. For more information see [https://spot.io/pricing/](https://spot.io/pricing/).
{{% /notice %}}

Next,  set your password, and verify your email by clicking the link in the verification email you will receive. This brings you to the console login page.

Once you’re logged in, you will find yourself in the Console.

#### Connecting Your AWS Account
Now, you will link your AWS account in order to enable the Spot.io platform to manage AWS resources on your behalf.

1. Make sure you are **logged in** to the [Console](https://console.spotinst.com/)
2. Select **Amazon Web Services** as the cloud provider.

<img src="/images/ocean/choose_cloud_provider.png" alt="Choose AWS Cloud Provider"/>

 {{% notice tip %}}
Prior to connecting your AWS account, you can access a preview of the console, by clicking on “Get a Console Walkthrough“.
 {{% /notice %}}
3. **Complete the process** by following the on-screen instructions. This will create the [IAM Role & Policy](https://api.spotinst.com/spotinst-api/administration/spotinst-policy/) necessary for the management of resources on your behalf.
 <img src="/images/ocean/connect_aws_account.png" alt="Connect AWS Account Steps" width="700"/>


{{% notice note %}}
Step 4 should be automated by the CFN stack, you should find your console ready for use once the stack has been created.
{{% /notice %}}

Feel free to follow the video tutorial below:

{{< youtube csPmq3JZlgU >}}

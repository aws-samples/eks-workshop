---
title: "Preparing to Install Container Insights"
chapter: false
weight: 4
---



<h3>Preparing to Install CloudWatch Container Insights:</h3>

The full documentation for CloudWatch Container Insights can be found here: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html 

<h4>Configuring IAM Access for CloudWatch Agent:</h4>

In order for CloudWatch to get the necessary monitoring info, we need to install the CloudWatch Agent to our EKS Cluster. 

In order to do so we first need to assign an IAM Policy. For the purpose of this lab, we will just attach the necessary IAM policy to the existing worker nodes attached policy which should have a name similar to eksctl-eksworkshop-eksctl-nodegro-NodeInstanceRole-XXXX

<h4>Add the necessary policy to the IAM role for your worker nodes</h4>

Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/ 

Select one of the worker node instances and choose the IAM role in the description.

<img src="/ekscloudwatchcontainerinsights/img/ec2info.png">

On the IAM role page, choose Attach policies. 

<img src="/ekscloudwatchcontainerinsights/img/attachpolicy.png">

In the list of policies, select the check box next to CloudWatchAgentServerPolicy. If necessary, use the search box to find this policy.

<img src="/ekscloudwatchcontainerinsights/img/attachperm.png">

Now we can proceed to the actual install of the CloudWatch Insights. 

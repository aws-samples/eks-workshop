---
title: "Preparing to Install Container Insights"
chapter: false
weight: 4
---



### Preparing to Install CloudWatch Container Insights:

The full documentation for CloudWatch Container Insights can be found here: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html 

#### Configuring IAM Access for CloudWatch Agent: 

In order for CloudWatch to get the necessary monitoring info, we need to install the CloudWatch Agent to our EKS Cluster. 

In order to do so we first need to assign an IAM Policy. For the purpose of this lab, we will just attach the necessary IAM policy to the existing worker nodes attached policy which should have a name similar to eksctl-eksworkshop-eksctl-nodegro-NodeInstanceRole-XXXX

#### Add the necessary policy to the IAM role for your worker nodes

Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/ 

Select one of the worker node instances and choose the IAM role in the description.


![alt text](/images/ekscwci/ec2info.png "EC2 Info")

On the IAM role page, choose Attach policies. 

![alt text](/images/ekscwci/attachpolicy.png "Attach IAM Policy")

In the list of policies, select the check box next to CloudWatchAgentServerPolicy. If necessary, use the search box to find this policy.

![alt text](/images/ekscwci/attachperm.png "Attach Permissions")

Now we can proceed to the actual install of the CloudWatch Insights. 

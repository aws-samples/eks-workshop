---
title: "Setup Container Insights"
chapter: false
weight: 1
---

There are 2 components that work together to collect Metrics, Logs data for Container Insights in EKS

1. CloudWatch agent
2. FluentD 

#### Application setup
In this section we will be setting up Container Insights for the ECS Demo app that you created in the [Deploy the Example Microservices](../../deploy) section earlier. If you haven't done that yet, go ahead and deploy the application and come back here again to proceed with Container Insights.

------------------------------------------------------------

#### Setup IAM role
In order for the EKS worker nodes to be able to send logs and metrics to CloudWatch, follow the steps below

* Open the [Amazon EC2 console](https://console.aws.amazon.com/ec2/)

* Select one of the worker node instances and choose the IAM role in the description.

* On the IAM role page, choose **Attach policies**.

* In the list of policies, select the check box next to **CloudWatchAgentServerPolicy**. If necessary, use the search box to find this policy.

* Choose **Attach policies**

------------------------------------------------------------

#### Setup Container Insights

{{< tabs name="Setup Instructions" >}}
{{{< tab name="LinuxmacOS" include="linuxmacos.md" />}}
{{{< tab name="Windows" include="windowsos.md" />}}
{{< /tabs >}}

{{% children showhidden="false" %}}

---
title: "Setup CloudWatch Alarm"
chapter: false
weight: 3
---
#### Setup CloudWatch Alarm

In this section, we will setup a CloudWatch alarm based on CPU Utilizaiton metric on a specific EKS worker node.

* Select any particular node you want and select **View in metrics** from the **CPU Utilization** widget as shown below

![Container Insights](/images/ContainerInsights7.png)

* Click on the bell icon (circled red in the screenshot below) to create the alarm

![Container Insights](/images/ContainerInsights8.png)

* In the next screen, enter 70 in the threshold textbox and leave everything as is. Click **Next**

![Container Insights](/images/ContainerInsights10.png)

* In **Configure actions** screen, select an existing SNS topic if you already have one, or create a new topic by selecting **Create new topic**, give the SNS topic a name and provide an email address to receive notifications from the topic. Click **Next**
![Container Insights](/images/ContainerInsights11.jpg)

* In the **Add a description** screen, enter a unique name for the alarm and click **Next**
* Click on **Create alarm** in the **Preview and create** screen. CloudWatch will send you a notification whenever the CPU utilization on the worker node goes beyond 70% for a period of 5 minutes
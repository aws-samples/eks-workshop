
---
title: "Using CloudWatch Alarms"
chapter: false
weight: 10
---

<h4> CloudWatch Alarms </h4>

You can use the CloudWatch metrics now to generate various alarms for your EKS Cluster based off assigned metrics. 

In CloudWatch Container Insights we’re going to drill down to create an alarm using CloudWatch for CPU Utilization for the Wordpress service. To do so click on the three vertical dots in the upper right of the CPU Utilization box. And select View in Metrics.

<img src="/ekscloudwatchcontainerinsights/img/viewinmetrics.png">

This will isolate us to a single pane view of CPU Utilization for the eksworkshop-eksctl cluster. 

<img src="/ekscloudwatchcontainerinsights/img/metricsview.png">

From this window we can create alarms for the understood-zebu-wordpress service so we know when it’s under heavy load. For this lab we’re going to set the threshold low so we can guarantee to set it off with the load test.

To create an alarm click on the small bell icon in line with the Wordpress service. 
This will take you to the metrics alarm configuration screen. 


<img src="/ekscloudwatchcontainerinsights/img/alarmconfig.png">



As we can see from the screen we peaked CPU at over 6 % so we’re going to set our metric to 3% to assure it sets off an alarm. Set your alarm to 50% of whatever you max was during the load test on the graph. 

Click next on the bottom and continue to Configure Actions.

<img src="/ekscloudwatchcontainerinsights/img/configactions.png">

We’re going to create a configuration to send an SNS alert to your email address when CPU gets above your threshold.

On the Configure Action screen:

- Leave default of in Alarm
- Select Create new Topic under Select and SNS Topic
- In Create new Topic.. name it wordpress-CPU-alert
- In Email Endpoints enter your email address
- Click create topic


Once those items are set, you can click Next at the bottom of the screen.

On the next screen we’ll add a unique name for our alert, and press Next.

<img src="/ekscloudwatchcontainerinsights/img/alertdescription.png">

The next screen will show your metric and the conditions. Make sure to click create alarm. 

<img src="/ekscloudwatchcontainerinsights/img/createalarm.png">


After creating your new SNS topic you will need to verify your subscription in your email.

<img src="/ekscloudwatchcontainerinsights/img/snsemail.png">

<h4> Testing your alarm </h4>

For the last step of this lab, we’re going to run one more load test on our site to verify our alarm triggers.  Go back to your Cloud9 terminal and run the same commands we can previously to load up our Wordpress site.

i.e. 
```
siege -c 200 -i http://a2d693dc5fbf411e9a4f202f7f69e9b7-1672154051.us-east-2.elb.amazonaws.com 
```
<i><font color="red">Make sure to modify the above URL to match your Wordpress site URL!</i></font>


After you let your load test run for a 20-30 seconds it will either complete, or you can kill the test. 

In a minute or two, you should receive and email about your CPU being in alert. If you don’t verify your SNS topic configuration and that you’ve accepted the subscription to the topic. 

<img src="/ekscloudwatchcontainerinsights/img/sampleemail.png">





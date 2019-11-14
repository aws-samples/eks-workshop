

---
title: "Viewing our collected metrics"
chapter: false
weight: 9
---


<h4>Now let's navigate to CloudWatch Container Insights to view the data we've generated. </h4>

https://console.aws.amazon.com/cloudwatch/home?region=us-east-2#cw:dashboard=Container;context=~(clusters~'eksworkshop-eksctl~dimensions~(~)~performanceType~'Service)   

From here you can choose a number of different views. We’re going to narrow down our timelines to a custom time rangeof just 30 minute so we can zoom into our recently collected insights. 

To do so go to the Time Range option at the top right of The CloudWatch Container Insights windows and selecting 30 minutes.

<img src="/images/ekscwci/metrictime.png">


Once zoomed in on the time frame we can see the large spike in resource usage for the load we just generated to the Wordpress service in our EKS Cluster.

<img src="/images/ekscwci/metriceksservice.png">

As mentioned previous you can view some different metrics based on the Dropdown menu options. Let's take a quick look at some of those items. 

<img src="/images/ekscwci/switches.gif">

## Next we are going to setup Alarms for metrics and test that they trigger ##
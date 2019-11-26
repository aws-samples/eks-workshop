---
title: "Verify CloudWatch Container Insights is working"
chapter: false
weight: 6
---



To verify that data is being collected in CloudWatch, launch the CloudWatch Containers UI in your browser: https://us-east-2.console.aws.amazon.com/cloudwatch/home?region=us-east-2#cw:dashboard=Container;context=~(clusters~'eksworkshop-eksctl~dimensions~(~)~performanceType~'Service  
{{% notice info %}} You may need to copy and paste the above link into your browser
{{% /notice %}} 

![alt text](/images/ekscwci/insights.png "Insights")




From here you can see the metrics are being collected and presented to CloudWatch. You can switch between various drop downs to see EKS Services, EKS Cluster and more. 

![alt text](/images/ekscwci/metricsoptions.png "Metrics Option")


#### We can now continue with load testing the cluster to see how these metrics can look under load. 



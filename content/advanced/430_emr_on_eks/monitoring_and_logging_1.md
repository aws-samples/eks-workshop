---
title: "Monitoring and logging Part 2 - Cloudwatch & S3"
date: 2021-04-08T04:25:46-07:00
weight: 31
draft: false
---

Let's head over to cloudwatch logs.

open the log group /emr-on-eks/eksworkshop-eksctl and filter stream by driver/stdout:

![EMR on EKS cloudwatch logs](/images/emr-on-eks/cloudwatch-logs1.png)

Now click on the log stream and you will be able to see the output of the job.

![EMR on EKS cloudwatch logs](/images/emr-on-eks/cloudwatch-stdout-1.png)


You can also go to the s3 bucket that we configured for logging and see the logs.

![EMR on EKS cloudwatch logs](/images/emr-on-eks/s3logs.png)

Download the stdout.gz file and extract it.

You should be able to find its contents similar as below:


> Pi is roughly 3.138760

Describe how to use spark history server, how to use S3 for logging, how to monitor jobs using prometheus & grafana.






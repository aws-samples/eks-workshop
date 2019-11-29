---
title: "Wrapping Up"
chapter: false
weight: 11
---

#### Wrapping Up:
As you can see it’s fairly easy to get CloudWatch Container Insights to work, and set alarms for CPU and other metrics. With CloudWatch Container Insights we remove the need to manage and update your own monitoring infrastructure and allow you to use native AWS solutions that you don’t have to manage the platform for.


***

#### Cleanup your Environment:

Let's clean up Wordpress so it's not running in your cluster any longer. 

```bash
helm delete understood-zebu
```

If you are completely done with EKSWorkshop, run the following command to clean up your cluster from your account.

```bash
eksctl delete cluster --name=eksworkshop-eksctl
```

## Thank you for using CloudWatch Container Insights! 

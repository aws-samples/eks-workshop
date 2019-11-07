---
title: "Wrapping Up"
chapter: false
weight: 11
---

<h4>Wrapping Up:</h4>
As you can see it’s fairly easy to get Cloud Watch Container Insights to work, and set alarms for CPU and other metrics. With CloudWatch Container Insights we remove the need to manage and update your own monitoring infrastructure and allow you to use native AWS solutions that you don’t have to manage the platform for.


***

<h4>Cleanup your Environment:</h4>

Let's clean up Wordpress so it's not running in your cluster any longer. 

```
helm delete stable/wordpress
```

If you are completely done with EKSWorkshop, run the following command to clean up your cluster from your account.

```
eksctl delete cluster --name=eksworkshop-eksctl
```

<h2> Thank you for using CloudWatch Container Insights! </h2>
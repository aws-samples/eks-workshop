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
helm uninstall understood-zebu
```

If you are completely done with EKSWorkshop, run the following command to clean up your cluster from your account.

```bash
eksctl delete cluster --name=eksworkshop-eksctl
```

{{% notice tip %}}
Without the `--wait` flag, this will only issue a delete operation to the cluster's CloudFormation stack and won't wait for its deletion. The `nodegroup` will have to complete the deletion process before the EKS cluster can be deleted. The total process will take approximately 15 minutes, and can be monitored via the [CloudFormation Console](https://console.aws.amazon.com/cloudformation/home).
{{% /notice %}}

## Thank you for using CloudWatch Container Insights!

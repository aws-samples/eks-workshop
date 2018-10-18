---
title: "Cleanup"
date: 2018-10-087T08:30:11-07:00
weight: 16
draft: true
---

Congratulations on making it through the CI/CD with CodePipline module.

This module is not used in subsequent steps, so you can remove the resources now, or at the end of the workshop.

First we need to delete the Kubernetes deployment and service:

```
kubectl delete deployments hello-k8s
kubectl delete services hello-k8s
```

Next, we are going to delete the CloudFormation stack created. Open up CloudFormation the [AWS Managemnt Console](https://console.aws.amazon.com/cloudformation).

Check the box next to the **eksws-codepipeline** stack, select the **Actions** dropdown menu and then click **Delete Stack**:

![CloudFormation Delete](/images/codepipeline/cloudformation_delete.png)

Now we are going to delete the [ECR respository](https://console.aws.amazon.com/ecs/home#/repositories):

![ECR Delete](/images/codepipeline/ecr_delete.png)

Finally, empty and then delete the [S3 bucket](https://s3.console.aws.amazon.com/s3/home) used by CodeBuild for build artifacts (bucket name starts with eksws-codepipeline). First,
you selete the bucket, then you empty the bucket and finally delete the bucket:

![S3 Delete](/images/codepipeline/s3_delete.png)


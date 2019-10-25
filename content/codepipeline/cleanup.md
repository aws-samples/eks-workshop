---
title: "Cleanup"
date: 2018-10-087T08:30:11-07:00
weight: 16
draft: false
---

Congratulations on completing the CI/CD with CodePipeline module.

This module is not used in subsequent steps, so you can remove the resources now, or at the end of the workshop.

First we need to delete the Kubernetes deployment and service:

```
kubectl delete deployments hello-k8s

kubectl delete services hello-k8s
```

Next, we are going to delete the CloudFormation stack created. Open CloudFormation the [AWS Management Console](https://console.aws.amazon.com/cloudformation).

Check the box next to the **eksws-codepipeline** stack, select the **Actions** dropdown menu and then click **Delete stack**:

![CloudFormation Delete](/images/codepipeline/cloudformation_delete.png)

Now we are going to delete the [ECR repository](https://console.aws.amazon.com/ecr/home#/repositories):

![ECR Delete](/images/codepipeline/ecr_delete.png)

Empty and then delete the [S3 bucket](https://s3.console.aws.amazon.com/s3/home) used by CodeBuild for build artifacts (bucket name starts with eksws-codepipeline). First,
select the bucket, then empty the bucket and finally delete the bucket:

![S3 Delete](/images/codepipeline/s3_delete.png)

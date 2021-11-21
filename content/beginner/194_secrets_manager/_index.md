---
title: "Mounting secrets from AWS Secrets Manager"
chapter: true
weight: 193
tags:
  - beginner
---

# Mounting secrets from AWS Secrets Manager

To show secrets from [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html) and parameters from [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/integrating_csi_driver.html) as mounted volumes in EKS pods, you can use the [AWS Secrets and Configuration Provider (ASCP)](https://github.com/aws/secrets-store-csi-driver-provider-aws) for [Kubernetes Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/).

With the ASCP, you retrieve secrets or parameters through your pods running on EKS. The values from secrets or parameters are available as projected volumes in your pod. The ASCP retrieves the pod identity and exchanges identity for an [IAM role for a Service Account (IRSA)](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/). It allows to limiting access to your secrets or parameters to specific pods from a namespace in the EKS cluster.

Optionally, The CSI driver can also sync your mounted secret volumes with native Kubernetes secrets. The volume mount in the pod is required for the sync, and only after that do the native Kubernetes secrets object appears. You can then also be able to populate Environment variables within a pod from Kubernetes secrets.


This section shows examples of how to use secrets from [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html). 

{{% notice tip %}}
Similar steps are required if you want to use parameters from [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/integrating_csi_driver.html).
{{% /notice %}}

After prerequisites are set up, the workflow is as follows:

1. Create a secret with the AWS Secrets Manager.
2. Create an IAM policy to retrieve a secret from the AWS Secrets Manager.
3. Use [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to limit secret access to your pods in a specific namespace.
4. Create and deploy SecretProviderClass custom resource and by using ```provider: aws```
5. Deploy your pods to mount the volumes based on SecretProviderClass configured earlier.
6. Access secrets within the container from the mounted volumes.
7. (Optional) Sync your secrets from mounted volumes to the native Kubernetes secrets object.
8. (Optional) Set up  Environment variables in the pod, by selecting a specific key of your secret. 

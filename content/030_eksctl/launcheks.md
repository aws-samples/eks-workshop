---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role](/020_prerequisites/workspaceiam/#validate-the-iam-role) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:

**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}
Run `aws sts get-caller-identity` and validate that your _Arn_ contains `eksworkshop-admin`and an Instance Id.

```output
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-admin/i-01234567890abcdef"
}
```

If you do not see the correct role, please go back and [validate the IAM role](/020_prerequisites/workspaceiam/#validate-the-iam-role) for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}

### Create an EKS cluster

{{% notice warning %}}
`eksctl` version must be 0.48.0 or above to deploy EKS 1.19, [click here](/030_eksctl/prerequisites) to get the latest version.
{{% /notice %}}

Create your cluster using the following syntax:

```bash
eksctl create cluster \
--name eksworkshop-eksctl \
--version 1.19 \
--tags cluster-type=workshop,department=dev \
--region "${AWS_REGION}" \
--zones "${AZS[0]},${AZS[1]},${AZS[2]}" \
--nodes 3 \
--node-type t3.medium \
--node-private-networking \
--enable-ssm \
--managed
```

Here we are creating EKS cluster with managed nodes by specifying `--managed` flag. It is good practice to tag resources in AWS for easier maintenance and cost allocation purpose. `--tags` option will propagate tags to ec2 instances and ebs volumes in cluster.
`eksctl` utility supports many other options to fine tune cluster, see [official documentation](https://eksctl.io/introduction/) to learn more about eksctl.

{{% notice info %}}
We are deliberatly launching one version behind the latest (1.19 vs. 1.20) to allow you to perform a cluster upgrade in one of the Chapters.
{{% /notice %}}

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}

Kubernetes secrets are just base64 encoded strings. It is highly recommended to encrypt secrets using trusted and secure encryption service. 
Next, we will enable kubernetes secrets encryption using AWS KMS. It will also encrypt existing secrets in cluster.
 
```bash
eksctl utils enable-secrets-encryption \
--region "${AWS_REGION}" \
--cluster eksworkshop-eksctl \
--encrypt-existing-secrets \
--key-arn "${MASTER_ARN}" \
--approve
```

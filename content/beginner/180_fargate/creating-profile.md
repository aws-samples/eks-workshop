---
title: "Creating a Fargate Profile"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

The [Fargate profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) allows an administrator to declare which pods run on Fargate. Each profile can have up to five selectors that contain a **namespace** and optional **labels**. You must define a namespace for every selector. The label field consists of multiple optional key-value pairs. Pods that match a selector (by matching a namespace for the selector and all of the labels specified in the selector) are scheduled on Fargate.

It is generally a good practice to deploy user application workloads into namespaces other than **kube-system** or **default** so that you have more fine-grained capabilities to manage the interaction between your pods deployed on to EKS. You will now create a new Fargate profile named **applications** that targets all pods destined for the **fargate** namespace.

#### Create a Fargate profile

```bash
eksctl create fargateprofile \
  --cluster eksworkshop-eksctl \
  --name game-2048 \
  --namespace game-2048
```

{{% notice info %}}
Fargate profiles are immutable. However, you can create a new updated profile to replace an existing profile and then delete the original after the updated profile has finished creating
{{% /notice %}}

When your EKS cluster schedules pods on Fargate, the pods will need to make calls to AWS APIs on your behalf to do things like pull container images from Amazon ECR. The Fargate **Pod Execution Role** provides the IAM permissions to do this. This IAM role is automatically created for you by the above command.

Creation of a Fargate profile can take up to several minutes. Execute the following command after the profile creation is completed and you should see output similar to what is shown below.

```bash
eksctl get fargateprofile \
  --cluster eksworkshop-eksctl \
  -o yaml
```

Output:
{{< output >}}
- name: game-2048
  podExecutionRoleARN: arn:aws:iam::197520326489:role/eksctl-eksworkshop-eksctl-FargatePodExecutionRole-1NOQE05JKQEED
  selectors:
  - namespace: game-2048
  subnets:
  - subnet-02783ce3799e77b0b
  - subnet-0aa755ffdf08aa58f
  - subnet-0c6a156cf3d523597
{{< /output >}}

Notice that the profile includes the private subnets in your EKS cluster. Pods running on Fargate are not assigned public IP addresses, so only private subnets (with no direct route to an Internet Gateway) are supported when you create a Fargate profile. Hence, while provisioning an EKS cluster, you must make sure that the VPC that you create contains one or more private subnets. When you create an EKS cluster with [eksctl](http://eksctl.io) utility, under the hoods it creates a VPC that meets these requirements.

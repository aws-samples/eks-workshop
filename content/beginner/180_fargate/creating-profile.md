---
title: "Creating a Fargate Profile"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

The [Fargate profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) allows an administrator to declare which pods run on Fargate. Each profile can have up to five selectors that contain a <b>namespace</b> and optional <b>labels</b>. You must define a namespace for every selector. The label field consists of multiple optional key-value pairs. Pods that match a selector (by matching a namespace for the selector and all of the labels specified in the selector) are scheduled on Fargate. 

It is generally a good practice to deploy user application workloads into namespaces other than <b>kube-system</b> or <b>default</b> so that you have more fine-grained capabilities to manage the interaction between your pods deployed on to EKS. You will now create a new Fargate profile named <b>applications</b> that targets all pods destined for the <b>fargate</b> namespace.



#### Create a Fargate profile
```
eksctl create fargateprofile --cluster eksworkshop-eksctl --name applications --namespace fargate
```
{{% notice info %}}
Fargate profiles are immutable. However, you can create a new updated profile to replace an existing profile and then delete the original after the updated profile has finished creating
{{% /notice %}}

When your EKS cluster schedules pods on Fargate, the pods will need to make calls to AWS APIs on your behalf to do things like pull container images from Amazon ECR. The Fargate <b>Pod Execution Role</b> provides the IAM permissions to do this. This IAM role is automatically created for you by the above command. 

Creation of a Fargate profile can take up to several minutes. Execute the following command after the profile creation is completed and you should see output similar to what is shown below.

```
eksctl get fargateprofile --cluster eksworkshop-eksctl -o yaml
```

Output: 
{{< output >}}
- name: applications
  podExecutionRoleARN: arn:aws:iam::937351930975:role/eksctl-k8s-sarathy-cluster-FargatePodExecutionRole-Z8OYLLNO3LZW
  selectors:
  - labels:
      app: nginx
    namespace: fargate
  subnets:
  - subnet-086fccc0cca20c36c
  - subnet-09c1ff46c36a39eea
  - subnet-06eef970ba0ac4829
{{< /output >}}

Notice that the profile includes the private subnets in your EKS cluster. Pods running on Fargate are not assigned public IP addresses, so only private subnets (with no direct route to an Internet Gateway) are supported when you create a Fargate profile. Hence, while provisioning an EKS cluster, you must make sure that the VPC that you create contains one or more private subnets. When you create an EKS cluster with [eksctl](http://eksctl.io) utility, under the hoods it creates a VPC that meets these requirements. 
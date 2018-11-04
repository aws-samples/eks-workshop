---
title: "Create the Worker ConfigMap"
date: 2018-08-07T12:00:40-07:00
weight: 70
draft: false
---

We have supplied an example configmap that we can use for our EKS workers. 

```
mkdir ~/environment/configmap
cd ~/environment/configmap
wget https://eksworkshop.com/spot/cloudformation/configmap.files/aws-cm-auth.yml
```
We need to substitute our instance role ARN into the template. 

1. Open the file in your Cloud9 editor

2. Find the section for RoleArn in the file and replace `<ARN of instance role (not instance profile)>` with the actual Role ARN from your worker nodes. 
{{% expand "Need help finding the Role ARN?" %}}
Search the [IAM Console](https://console.aws.amazon.com/iam/home?#/roles) for a role containing **nodegroup**
{{% /expand %}}

3. Save the file and apply the manifest in your terminal
```
kubectl apply -f ~/environment/configmap/aws-cm-auth.yml
```

{{%attachments title="Related files" pattern=".yml"/%}}
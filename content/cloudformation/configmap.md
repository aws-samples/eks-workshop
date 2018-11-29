---
title: "Create the Worker ConfigMap"
date: 2018-08-07T12:00:40-07:00
weight: 70
draft: false
---

We have supplied an example ConfigMap that we can use for our EKS workers. This ConfigMap will be used to whitelist the workers to join the cluster via Kubernetes RBAC.

Download the template to the Cloud9 environment.

```bash
mkdir ~/environment/configmap
cd ~/environment/configmap
wget https://eksworkshop.com/spot/cloudformation/configmap.files/aws-cm-auth.yml
```

We need to substitute our instance role ARN into the Config Map template. Open the template in the editor of your choice.

#### Challenge:
**Add your Worker Node Role ARN to the ConfigMap**
{{% expand "Expand here to see the solution" %}}
Find the section for RoleArn in the file and replace `<ARN of instance role (not instance profile)>` with the actual Role ARN from your worker nodes.

If you need help finding the Role ARN, search the [IAM Console](https://console.aws.amazon.com/iam/home?#/roles) for a role containing **nodegroup**.
{{% /expand %}}

Save the file and apply the manifest in your terminal

```bash
kubectl apply -f ~/environment/configmap/aws-cm-auth.yml
```

{{%attachments title="Related files" pattern=".yml"/%}}
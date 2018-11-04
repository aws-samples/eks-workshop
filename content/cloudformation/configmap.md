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
We need to substitute our instance role ARN into the template. Open the file in your Cloud9 editor.

Find the RoleArn and replace `<ARN of instance role (not instance profile)>` with the actual Role ARN from your worker nodes.

Save the file and apply the manifest in your terminal.

```
kubectl apply -f ~/environment/configmap/aws-cm-auth.yml
```

Confirm your can see your worker nodes
```
kubectl get nodes
```


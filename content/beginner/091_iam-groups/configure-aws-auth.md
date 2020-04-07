---
title: "Configure Kubernetes Role Access"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 31
---

#### Gives Access to our IAM Roles to EKS Cluster

In order to gives access to the IAM Roles we defined previously to our EKS cluster, we need to add specific **mapRoles** to the `aws-auth` ConfigMap

The Advantage of using Role to access the cluster instead of specifying directly IAM users is that it will be easier to manage: 
we won't have to update the ConfigMap each time we want to add or remove users, we will just need to add or remove users from 
the IAM Group and we just configure the ConfigMap to allow the IAM Role associated to the IAM Group.

### Update the aws-auth ConfigMap to allow our IAM roles

The **aws-auth** ConfigMap from the kube-system namespace must be edited in order to allow or new arn Groups.

This file makes the mapping between IAM role and k8S RBAC rights. We can edit it manually:

We can edit it using [eksctl](https://github.com/weaveworks/eksctl) :

```
eksctl create iamidentitymapping --cluster eksworkshop-eksctl --arn arn:aws:iam::${ACCOUNT_ID}:role/k8sDev --username dev-user
eksctl create iamidentitymapping --cluster eksworkshop-eksctl --arn arn:aws:iam::${ACCOUNT_ID}:role/k8sInteg --username integ-user
eksctl create iamidentitymapping --cluster eksworkshop-eksctl --arn arn:aws:iam::${ACCOUNT_ID}:role/k8sAdmin --username admin --group system:masters
```
> It cal also be used to delete entries
> `eksctl delete iamidentitymapping --cluster eksworkshop-eksctlv --arn arn:aws:iam::xxxxxxxxxx:role/k8sDev --username dev-user`

you should have the config map looking something like:

```
kubectl get cm -n kube-system aws-auth -o yaml
```

{{< output >}}
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::xxxxxxxxxx:role/eksctl-eksworkshop-eksctl-nodegro-NodeInstanceRole-14TKBWBD7KWFH
      username: system:node:{{EC2PrivateDNSName}}
    - rolearn: arn:aws:iam::xxxxxxxxxx:role/k8sDev
      username: dev-user
    - rolearn: arn:aws:iam::xxxxxxxxxx:role/k8sInteg
      username: integ-user
    - groups:
      - system:masters
      rolearn: arn:aws:iam::xxxxxxxxxx:role/k8sAdmin
      username: admin
  mapUsers: |
    []
kind: ConfigMap
{{< /output >}}

We can leverage eksctl to get a list of all identity managed in our cluster. Example:

```
eksctl get iamidentitymapping --cluster eksworkshop-eksctl
```

{{< output >}}
arn:aws:iam::xxxxxxxxxx:role/eksctl-quick-nodegroup-ng-fe1bbb6-NodeInstanceRole-1KRYARWGGHPTT	system:node:{{EC2PrivateDNSName}}	system:bootstrappers,system:nodes
arn:aws:iam::xxxxxxxxxx:role/k8sAdmin           admin					system:masters
arn:aws:iam::xxxxxxxxxx:role/k8sDev             dev-user
arn:aws:iam::xxxxxxxxxx:role/k8sInteg           integ-user
{{< /output >}}

Here we have created:

- a RBAC role for K8sAdmin, that we map to admin user and give access to **system:masters** kubernetes Groups (so that it has Full Admin rights)
- a RBAC role for k8sDev that we map on dev-user in development namespace
- a RBAC role for k8sInteg that we map on integ-user in integration namespace

We will see on next section how we can test it.
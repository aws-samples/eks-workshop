---
title: "Specifying an IAM Role for Service Account"
date: 2018-11-13T16:36:24+09:00
weight: 40
draft: false
---

### Specifying an IAM Role for your Service Account

In the previous step, we created the IAM role that associated with a service account named **iam-test** in the cluster and this has already been done for you with the service account you specified when creating the role.

##### Be sure your service account iam-test is exist:

```
kubectl get sa
```

| NAME | SECRETS | AGE |
| ---- | ------- | --- |
| default | 1 | 85m |
| **iam-test** | 1 | 44m |

##### Make sure your service account with the ARN of the IAM role is annotated:

```
kubectl describe sa iam-test
```
{{< output >}}

Name:                iam-test
Namespace:           default
Labels:              <none>
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::14xxxxxxxx84:role/eksctl-eksworkshop-eksctl-addon-iamserviceac-Role1-1PJ5Q3H39Z5M9
Image pull secrets:  <none>
Mountable secrets:   iam-test-token-5n9cb
Tokens:              iam-test-token-5n9cb
Events:              <none>
{{< /output >}}

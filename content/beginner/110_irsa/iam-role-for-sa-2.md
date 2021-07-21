---
title: "Specifying an IAM Role for Service Account"
date: 2021-07-20T00:00:00-03:00
weight: 40
draft: false
---

In the previous step, we created the IAM role that is associated with a service account named **iam-test** in the cluster.

First, let's verify your service account `iam-test` exists

```bash
kubectl get sa iam-test
```

{{< output >}}
NAME       SECRETS   AGE
iam-test   1         5m
{{< /output >}}

Make sure your service account with the ARN of the IAM role is annotated

```bash
kubectl describe sa iam-test
```

{{< output >}}
Name:                iam-test
Namespace:           default
Labels:              app.kubernetes.io/managed-by=eksctl
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::40XXXXXXXX75:role/eksctl-sandbox-addon-iamserviceaccount-defau-Role1-1B37L4A1UEXYS
Image pull secrets:  <none>
Mountable secrets:   iam-test-token-zbk55
Tokens:              iam-test-token-zbk55
Events:              <none>
{{< /output >}}

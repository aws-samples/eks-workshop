---
title: "Map an IAM User to K8s"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 30
---

Next, we'll define a k8s user called rbac-user, and map to it's IAM user counterpart.  Run the following to create a ConfigMap called aws-auth.yaml that creates this mapping:

```
cat << EoF > aws-auth.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: arn:aws:iam::${ACCOUNT_ID}:user/rbac-user
      username: rbac-user
EoF
```

Some of the values may be dynamically populated when the file is created.  To verify everything populated and was created correctly, run the following:

```
cat aws-auth.yaml
```

And the output should reflect that rolearn and userarn populated, similar to:

{{< output >}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: arn:aws:iam::123456789:user/rbac-user
      username: rbac-user
{{< /output >}}

Next, apply the ConfigMap to apply this mapping to the system:

```
kubectl apply -f aws-auth.yaml
```

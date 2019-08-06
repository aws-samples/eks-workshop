---
title: "Map an IAM User to K8s"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 30
---

Next, we'll define a k8s user called rbac-user, and map to it's IAM user counterpart.  Run the following to create a ConfigMap called aws-auth.yaml that creates this mapping:


{{< tabs name="Map the User" >}}

{{{< tab name="Workshop at AWS event" codelang="output" >}}

cat << EoF > aws-auth.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${ROLE_NAME}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::749670941601:user/rbac-user
      username: rbac-user
EoF

{{< /tab >}}

{{< tab name="Workshop in your own account" codelang="output" >}}

cat << EoF > aws-auth.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${ROLE_NAME}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::$(aws sts get-caller-identity --output text --query Account):user/rbac-user
      username: rbac-user
EoF

{{< /tab >}}}
{{< /tabs >}}

Some of the values may be dynamically populated when the file is created.  To verify everything populated and was created correctly, run the following:

```
cat aws-auth.yaml
```

And the output should reflect that rolearn and userarn populated, similar to:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::123:role/eksctl-eksworkshop-eksctl-nodegroup-ng-ae-NodeInstanceRole-JEJWYEB12TNF
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::123:user/rbac-user
      username: rbac-user
```

Next, apply the ConfigMap to apply this mapping to the system:

```
kubectl apply -f aws-auth.yaml
```

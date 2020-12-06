---
title: "Modify aws-auth ConfigMap"
date: 2018-10-087T08:30:11-07:00
weight: 11
draft: false
---

Now that we have the IAM role created, we are going to add the role to the [aws-auth ConfigMap](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)
for the EKS cluster.

Once the ConfigMap includes this new role, kubectl in the CodeBuild stage of the pipeline will be able to interact with the EKS cluster via the IAM role.

```
ROLE="    - rolearn: arn:aws:iam::${ACCOUNT_ID}:role/EksWorkshopCodeBuildKubectlRole\n      username: build\n      groups:\n        - system:masters"

kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml

kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"
```


{{% notice tip %}}
If you would like to edit the aws-auth ConfigMap manually, you can run: $ kubectl edit -n kube-system configmap/aws-auth
{{% /notice %}}

---
title: "Create IAM Roles"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 20
---

We are going to create 3 roles:

- a **k8sAdmin** role which will have **admin**x rights in our EKS cluster
- a **k8sDev** role which will gives access to **developers** namespace in our EKS cluster
- a **k8sInteg** role which will gives access to **integration** namespace our EKS cluster

Create the roles:

```
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
POLICY=$(echo -n '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':root"},"Action":"sts:AssumeRole","Condition":{}}]}')
echo ACCOUNT_ID=$ACCOUNT_ID
echo POLICY=$POLICY

aws iam create-role \
  --role-name k8sAdmin \
  --description "Kubernetes administrator role (for AWS IAM Authenticator for Kubernetes)." \
  --assume-role-policy-document "$POLICY" \
  --output text \
  --query 'Role.Arn'

aws iam create-role \
  --role-name k8sDev \
  --description "Kubernetes developer role (for AWS IAM Authenticator for Kubernetes)." \
  --assume-role-policy-document "$POLICY" \
  --output text \
  --query 'Role.Arn'
  
aws iam create-role \
  --role-name k8sInteg \
  --description "Kubernetes role for integration namespace in quick cluster." \
  --assume-role-policy-document "$POLICY" \
  --output text \
  --query 'Role.Arn'
```

> In this example, the assume-role-policy allows the root account to assume the role. 
We are going to allow specific groups to also be able to assume thoses roles.

> check the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html) for more informations: 
> 

Because the above roles are only used to authenticate within the k8s cluster, they don't necessary need to have AWS permissions. 
We will only uses them to allow some IAM groups to assume this role in order to have acess to EKS kubernetes cluster.


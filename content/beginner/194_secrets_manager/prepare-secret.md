---
title: "Prepare secret and IAM access controls"
date: 2021-10-01T00:00:00-04:00
weight: 20
draft: false
---

#### Set variables
Verify AWS_REGION variable. 
```bash
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
```
If not set, then complete [Start the workshop instructions](/020_prerequisites/workspaceiam/) and verify again.

Set the cluster name variable.
```bash
export EKS_CLUSTERNAME="eksworkshop-eksctl"
```

#### Create a test secret with the AWS Secrets Manager.
```bash
aws --region "$AWS_REGION" secretsmanager \
  create-secret --name DBSecret_eksworkshop \
  --secret-string '{"username":"foo", "password":"super-sekret"}'
```

Get secret's ARN.

```bash
SECRET_ARN=$(aws --region "$AWS_REGION" secretsmanager \
    describe-secret --secret-id  DBSecret_eksworkshop \
    --query 'ARN' | sed -e 's/"//g' )

echo $SECRET_ARN
```

You can also verify the newly created secret via AWS console under [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?#!/secret?name=DBSecret_eksworkshop) 

![DBSecret_eksworkshop](/images/secret-in-secretsManager.png)


#### Create an IAM policy
Create an IAM with permissions to access the secret.

```bash
IAM_POLICY_NAME_SECRET="DBSecret_eksworkshop_secrets_policy_$RANDOM"
IAM_POLICY_ARN_SECRET=$(aws --region "$AWS_REGION" iam \
	create-policy --query Policy.Arn \
    --output text --policy-name $IAM_POLICY_NAME_SECRET \
    --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["'"$SECRET_ARN"'" ]
    } ]
}')

echo $IAM_POLICY_ARN_SECRET | tee -a 00_iam_policy_arn_dbsecret
```

#### Create a Service Account with IAM role 
User [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)  and create an IAM role bound to a service account with *read* access to the secret. 

```bash
eksctl utils associate-iam-oidc-provider \
    --region="$AWS_REGION" --cluster="$EKS_CLUSTERNAME" \
    --approve

eksctl create iamserviceaccount \
    --region="$AWS_REGION" --name "nginx-deployment-sa"  \
    --cluster "$EKS_CLUSTERNAME" \
    --attach-policy-arn "$IAM_POLICY_ARN_SECRET" --approve \
    --override-existing-serviceaccounts
```

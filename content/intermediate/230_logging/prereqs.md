---
title: "Configure IRSA for Fluent Bit"
date: 2018-08-07T08:30:11-07:00
weight: 10
---
{{% notice note %}}
[Click here](/beginner/110_irsa/) if you are not familiar wit IAM Roles for Service Accounts (IRSA).
{{% /notice %}}

With IAM roles for service accounts on Amazon EKS clusters, you can associate an IAM role with a Kubernetes service account. This service account can then provide AWS permissions to the containers in any pod that uses that service account. With this feature, you no longer need to provide extended permissions to the node IAM role so that pods on that node can call AWS APIs.

#### Enabling IAM roles for service accounts on your cluster

To use IAM roles for service accounts in your cluster, we will first create an OIDC identity provider

```bash
eksctl utils associate-iam-oidc-provider \
    --cluster eksworkshop-eksctl \
    --approve
```

#### Creating an IAM role and policy for your service account

Next, we will create an IAM policy that limits the permissions needed by the Fluent Bit containers to connect to the Elasticsearch cluster.
We will also create an IAM role for your Kubernetes service accounts to use before you associate it with a service account.

```bash
mkdir ~/environment/logging/

export ES_DOMAIN_NAME="eksworkshop-logging"

cat <<EoF > ~/environment/logging/fluent-bit-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "es:ESHttp*"
            ],
            "Resource": "arn:aws:es:${AWS_REGION}:${ACCOUNT_ID}:domain/${ES_DOMAIN_NAME}",
            "Effect": "Allow"
        }
    ]
}
EoF

aws iam create-policy   \
  --policy-name fluent-bit-policy \
  --policy-document file://~/environment/logging/fluent-bit-policy.json
```

#### Create an IAM role

Finally, create an IAM role for the fluent-bit Service Account in the logging namespace.

```bash
kubectl create namespace logging

eksctl create iamserviceaccount \
    --name fluent-bit \
    --namespace logging \
    --cluster eksworkshop-eksctl \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/fluent-bit-policy" \
    --approve \
    --override-existing-serviceaccounts
```

#### Make sure your service account with the ARN of the IAM role is annotated

```bash
kubectl -n logging describe sa fluent-bit
```

Output

{{< output >}}
Name:                fluent-bit
Namespace:           logging
Labels:              <none>
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::197520326489:role/eksctl-eksworkshop-eksctl-addon-iamserviceac-Role1-1V7G71K6ZN8ID
Image pull secrets:  <none>
Mountable secrets:   fluent-bit-token-qxdtx
Tokens:              fluent-bit-token-qxdtx
Events:              <none>
{{< /output >}}

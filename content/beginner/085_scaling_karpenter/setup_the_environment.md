---
title: "Set up the environment"
weight: 10
draft: false
---

Before we install Karpenter, there are a few things that we will need to prepare in our environment for it to work as expected.

## Environment Variables

Set the following environment variable to the Karpenter version you would like to install.
```bash
export KARPENTER_VERSION=v0.16.0
```

Also set the following environment variables to store commonly used values.

```bash
export CLUSTER_NAME=$(eksctl get clusters -o json | jq -r '.[0].Name')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
```

## Create the KarpenterNode IAM Role

Instances launched by Karpenter must run with an InstanceProfile that grants permissions necessary to run containers and configure networking. Karpenter discovers the InstanceProfile using the name `KarpenterNodeRole-${ClusterName}`. 

First, create the IAM resources using AWS CloudFormation.

```bash
TEMPOUT=$(mktemp)

curl -fsSL https://karpenter.sh/"${KARPENTER_VERSION}"/getting-started/getting-started-with-eksctl/cloudformation.yaml  > $TEMPOUT \
&& aws cloudformation deploy \
  --stack-name "Karpenter-${CLUSTER_NAME}" \
  --template-file "${TEMPOUT}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "ClusterName=${CLUSTER_NAME}"
```

{{% notice tip %}}
This step may take about 2 minutes. In the meantime, you can [download the file](https://karpenter.sh/v0.15.0/getting-started/getting-started-with-eksctl/cloudformation.yaml) and check the content of the CloudFormation Stack. Check how the stack defines a policy, a role and and Instance profile that will be used to associate to the instances launched. You can also head to the **CloudFormation** console and check which resources does the stack deploy.
{{% /notice %}}

Second, grant access to instances using the profile to connect to the cluster. This command adds the Karpenter node role to your aws-auth configmap, allowing nodes with this role to connect to the cluster.

```bash
eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster  ${CLUSTER_NAME} \
  --arn "arn:aws:iam::${ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}" \
  --group system:bootstrappers \
  --group system:nodes
```

You can verify the entry is now in the AWS auth map by running the following command. 

```bash
kubectl describe configmap -n kube-system aws-auth
```

## Create KarpenterController IAM Role

Before adding the IAM Role for the service account we need to create the IAM OIDC Identity Provider for the cluster. 

```bash
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve
```

Karpenter requires permissions like launching instances. This will create an AWS IAM Role, Kubernetes service account, and associate them using [IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)

```bash
eksctl create iamserviceaccount \
  --cluster "${CLUSTER_NAME}" --name karpenter --namespace karpenter \
  --role-name "${CLUSTER_NAME}-karpenter" \
  --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}" \
  --role-only \
  --approve

export KARPENTER_IAM_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${CLUSTER_NAME}-karpenter"
```

{{% notice note %}}
This step may take up to 2 minutes. eksctl will create and deploy a CloudFormation stack that defines the role and create the kubernetes resources that define the Karpenter `serviceaccount` and the `karpenter` namespace that we will use during the workshop. You can also check in the **CloudFormation** console, the resources this stack creates.
{{% /notice %}}

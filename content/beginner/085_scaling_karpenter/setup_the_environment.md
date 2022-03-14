---
title: "Set up the environment"
weight: 10
draft: false
---

Before we install Karpenter, there are a few things that we will need to prepare in our environment for it to work as expected.

## Pre-requisites

```bash
export CLUSTER_NAME=$(eksctl get clusters -o json | jq -r '.[0].metadata.name')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
```


## Tagging Subnets


Karpenter discovers subnets tagged `kubernetes.io/cluster/$CLUSTER_NAME`. We need to add this tag to the subnets associated to your cluster. The following command retreives the subnet IDs from cloudformation and tags them with the appropriate cluster name.

```
SUBNET_IDS=$(aws cloudformation describe-stacks \
    --stack-name eksctl-${CLUSTER_NAME}-cluster \
    --query 'Stacks[].Outputs[?OutputKey==`SubnetsPrivate`].OutputValue' \
    --output text)
aws ec2 create-tags \
    --resources $(echo $SUBNET_IDS | tr ',' '\n') \
    --tags Key="kubernetes.io/cluster/${CLUSTER_NAME}",Value=
```

You can verify the right tags have been set by running the following command. This commands checks which subnets have the `kubernetes.io/cluster/${CLUSTER_NAME}` and compares them to the cluster subnets. Note the elements in the equation can be out of order.

```
VALIDATION_SUBNETS_IDS=$(aws ec2 describe-subnets --filters Name=tag:"kubernetes.io/cluster/${CLUSTER_NAME}",Values= --query "Subnets[].SubnetId" --output text | sed 's/\t/,/')
echo "$SUBNET_IDS == $VALIDATION_SUBNETS_IDS"
```

## Create the IAM Role and Instance profile for Karpenter Nodes 

Instances launched by Karpenter must run with an InstanceProfile that grants permissions necessary to run containers and configure networking. Karpenter discovers the InstanceProfile using the name `KarpenterNodeRole-${ClusterName}`.

```bash
export KARPENTER_VERSION=v0.6.4
TEMPOUT=$(mktemp)
curl -fsSL https://karpenter.sh/"${KARPENTER_VERSION}"/getting-started/cloudformation.yaml > $TEMPOUT \
&& aws cloudformation deploy \
  --stack-name Karpenter-${CLUSTER_NAME} \
  --template-file ${TEMPOUT} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides ClusterName=${CLUSTER_NAME}
```

{{% notice tip %}}
This step may take about 2 minutes. In the meantime, you can [download the file](https://karpenter.sh/docs/getting-started/cloudformation.yaml) and check the content of the CloudFormation Stack. Check how the stack defines a policy, a role and and Instance profile that will be used to associate to the instances launched. You can also head to the **CloudFormation** console and check which resources does the stack deploy.
{{% /notice %}}

Second, grant access to instances using the profile to connect to the cluster. This command adds the Karpenter node role to your aws-auth configmap, allowing nodes with this role to connect to the cluster.

```bash
eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster  ${CLUSTER_NAME} \
  --arn arn:aws:iam::${ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME} \
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
  --cluster $CLUSTER_NAME --name karpenter --namespace karpenter \
  --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/KarpenterControllerPolicy-$CLUSTER_NAME \
  --approve
```

{{% notice note %}}
This step may take up to 2 minutes. eksctl will create and deploy a CloudFormation stack that defines the role and create the kubernetes resources that define the Karpenter `serviceaccount` and the `karpenter` namespace that we willuse during the workshop. You can also check in the **CloudFormation** console, the resources this stack creates.
{{% /notice %}}


You can confirm the service account has been created by running:

```bash
kubectl get serviceaccounts --namespace karpenter
```

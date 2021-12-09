---
title: "Configure Karpenter"
date: 2021-12-09T08:30:11-07:00
weight: 60
---

Karpenter is an open-source node provisioning project built for Kubernetes. Its goal is to improve the efficiency and cost of running workloads on Kubernetes clusters. Karpenter works by:

Watching for pods that the Kubernetes scheduler has marked as unschedulable
Evaluating scheduling constraints (resource requests, nodeselectors, affinities, tolerations, and topology spread constraints) requested by the pods
Provisioning nodes that meet the requirements of the pods
Scheduling the pods to run on the new nodes
Removing the nodes when the nodes are no longer needed
For most use cases, a cluster’s capacity can be managed by a single Karpenter Provisioner. However, you can define multiple Provisioners, enabling use cases like isolation, entitlements, and sharding. Using a combination of defaults and overrides, Karpenter determines the availability zone, instance type, capacity type, machine image, and scheduling constraints for pods it manages.

Karpenter is an alternative to clusster autoscaler but not mutually exclusive.

## Pre-requisites

```bash
export CLUSTER_NAME=$(eksctl get clusters -o json | jq -r '.[0].metadata.name')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
```

## Tag Subnets

Karpenter discovers subnets tagged kubernetes.io/cluster/$CLUSTER_NAME. Add this tag to subnets associated configured for your cluster. Retreive the subnet IDs and tag them with the cluster name.

```bash
SUBNET_IDS=$(aws cloudformation describe-stacks \
    --stack-name eksctl-${CLUSTER_NAME}-cluster \
    --query 'Stacks[].Outputs[?OutputKey==`SubnetsPrivate`].OutputValue' \
    --output text)
aws ec2 create-tags \
    --resources $(echo $SUBNET_IDS | tr ',' '\n') \
    --tags Key="kubernetes.io/cluster/${CLUSTER_NAME}",Value=
    
```

## Create the KarpenterNode IAM Role

Instances launched by Karpenter must run with an InstanceProfile that grants permissions necessary to run containers and configure networking. Karpenter discovers the InstanceProfile using the name KarpenterNodeRole-${ClusterName}.

First, create the IAM resources using AWS CloudFormation.

```bash
TEMPOUT=$(mktemp)
curl -fsSL https://karpenter.sh/docs/getting-started/cloudformation.yaml > $TEMPOUT \
&& aws cloudformation deploy \
  --stack-name Karpenter-${CLUSTER_NAME} \
  --template-file ${TEMPOUT} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides ClusterName=${CLUSTER_NAME}
```

Second, grant access to instances using the profile to connect to the cluster. This command adds the Karpenter node role to your aws-auth configmap, allowing nodes with this role to connect to the cluster.

```bash
eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster  ${CLUSTER_NAME} \
  --arn arn:aws:iam::${ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME} \
  --group system:bootstrappers \
  --group system:nodes
```

Now, Karpenter can launch new EC2 instances and those instances can connect to your cluster.

## Create the KarpenterController IAM Role

Karpenter requires permissions like launching instances. This will create an AWS IAM Role, Kubernetes service account, and associate them using IRSA.

To use IAM roles for service accounts in your cluster, we will first create an OIDC identity provider

```bash
eksctl utils associate-iam-oidc-provider \
    --cluster $CLUSTER_NAME \
    --approve
```

Create an AWS IAM Role, Kubernetes service account, and associate them using IRSA.

```bash
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME --name karpenter --namespace karpenter \
  --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/KarpenterControllerPolicy-$CLUSTER_NAME \
  --approve
```

## Install Karpenter Helm Chart

Use helm to deploy Karpenter to the cluster.

```bash
helm repo add karpenter https://charts.karpenter.sh
helm repo update
helm upgrade --install karpenter karpenter/karpenter --namespace karpenter \
  --create-namespace --set serviceAccount.create=false --version 0.4.3 \
  --set controller.clusterName=${CLUSTER_NAME} \
  --set controller.clusterEndpoint=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output json) \
  --set defaultProvisioner.create=false \
  --wait # for the defaulting webhook to install before creating a Provisioner
```

## Provisioner

A single Karpenter provisioner is capable of handling many different pod shapes. Karpenter makes scheduling and provisioning decisions based on pod attributes such as labels and affinity. In other words, Karpenter eliminates the need to manage many different node groups.

Create a default provisioner using the command below. This provisioner configures instances to connect to your cluster’s endpoint and discovers resources like subnets and security groups using the cluster’s name.

The ```ttlSecondsAfterEmpty``` value configures Karpenter to terminate empty nodes. This behavior can be disabled by leaving the value undefined.

Review the [provisioner CRD](https://karpenter.sh/v0.4.3-docs/provisioner-crd/) for more information. For example, ttlSecondsUntilExpired configures Karpenter to terminate nodes when a maximum age is reached.


[default is on-demand] -> add for spot?


```bash
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  provider:
    instanceProfile: KarpenterNodeInstanceProfile-${CLUSTER_NAME}
  ttlSecondsAfterEmpty: 30
EOF
```

## Karpenter in-action

Karpenter is now active and ready to begin provisioning nodes. Create some pods using a deployment, and watch Karpenter provision nodes in response.

This deployment uses the pause image and starts with zero replicas. We then look at the karpenter logs.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate
  template:
    metadata:
      labels:
        app: inflate
    spec:
      containers:
        - name: inflate
          image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
          resources:
            requests:
              cpu: 1
EOF
kubectl scale deployment inflate --replicas 15
kubectl logs -f -n karpenter $(kubectl get pods -n karpenter -l karpenter=controller -o name)
```

Now, delete the deployment. After 30 seconds (ttlSecondsAfterEmpty), Karpenter should terminate the now empty nodes.

```bash
kubectl delete deployment inflate
kubectl logs -f -n karpenter $(kubectl get pods -n karpenter -l karpenter=controller -o name)
```


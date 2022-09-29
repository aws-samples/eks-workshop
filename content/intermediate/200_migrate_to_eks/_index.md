---
title: "Migrate to EKS"
chapter: true
weight: 200
tags:
  - intermediate
---

# Migrate Workloads to EKS

![counter app recording](/images/migrate_to_eks/counter-app.gif)

In this chapter we will migrate a workload from a self managed kind cluster to an EKS cluster.
The workload will have a stateless frontend and a stateful database backend.
You'll need to follow the steps to create a [Cloud9 workspace]({{< ref "020_prerequisites/workspace.md" >}}).
Make sure you [update your IAM permissions]({{< ref "020_prerequisites/iamrole.md" >}}) with an eksworkshop-admin role.

{{% notice note %}}
When you create your Cloud9 instance you should select an instance size with at least 8 GB of memory (eg m5.large) because we are going to create a [`kind`](https://kind.sigs.k8s.io) cluster we will migrate workloads from. 
{{% /notice %}}

We'll need a few environment variables throughout this section so let's set those up now.
Unless specified all commands should be run from your Cloud9 instance.

```bash
export CLUSTER=eksworkshop-eksctl
export AWS_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_DEFAULT_REGION=${AWS_REGION}
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export MAC=$(curl -s http://169.254.169.254/latest/meta-data/mac)
export SECURITY_GROUP=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/security-group-ids)
export SUBNET=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/subnet-id)
export VPC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/vpc-id)
export IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

printf "export CLUSTER=$CLUSTER\nexport ACCOUNT_ID=$ACCOUNT_ID\nexport AWS_REGION=$AWS_REGION\nexport AWS_DEFAULT_REGION=${AWS_REGION}\nexport AWS_ZONE=$AWS_ZONE\nexport INSTANCE_ID=$INSTANCE_ID\nexport MAC=$MAC\nexport SECURITY_GROUP=$SECURITY_GROUP\nexport SUBNET=$SUBNET\nexport VPC=$VPC\nexport IP=$IP" | tee -a ~/.bash_profile
. ~/.bash_profile
```

Install `kind`

```bash
# install kind
curl -sLo kind "https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64"
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
rm -f ./kind
```

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
export CLUSTER=eksworkshop
export AWS_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_REGION=${AWS_ZONE::-1}
export AWS_DEFAULT_REGION=${AWS_REGION}
export ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export MAC=$(curl -s http://169.254.169.254/latest/meta-data/mac)
export SECURITY_GROUP=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/security-group-ids)
export SUBNET=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/subnet-id)
export VPC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/vpc-id)
export IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

printf "export CLUSTER=$CLUSTER\nexport ACCOUNT_ID=$ACCOUNT_ID\nexport AWS_REGION=$AWS_REGION\nexport AWS_DEFAULT_REGION=${AWS_REGION}\nexport AWS_ZONE=$AWS_ZONE\nexport INSTANCE_ID=$INSTANCE_ID\nexport MAC=$MAC\nexport SECURITY_GROUP=$SECURITY_GROUP\nexport SUBNET=$SUBNET\nexport VPC=$VPC\nexport IP=$IP" | tee -a ~/.bash_profile
. ~/.bash_profile
```

Now we can [expand the Cloud9 root volume]({{< ref "020_prerequisites/workspace#increase-the-disk-size-on-the-cloud9-instance" >}})

```bash
curl -sL 'https://eksworkshop.com/intermediate/200_migrate_to_eks/resize-ebs.sh' | bash
```

Install `kubectl`, `kind`, `aws-iam-authenticator`, `eksctl` and update `aws`

```bash
# Install kubectl
curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f ./kubectl

# install eksctl
curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
tar xz -C /tmp -f "eksctl_$(uname -s)_amd64.tar.gz"
sudo install -o root -g root -m 0755 /tmp/eksctl /usr/local/bin/eksctl
rm -f ./"eksctl_$(uname -s)_amd64.tar.gz"

# install aws-iam-authenticator
curl -sLO "https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator"
sudo install -o root -g root -m 0755 aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
rm -f ./aws-iam-authenticator

# install kind
curl -sLo kind "https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64"
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
rm -f ./kind

# install awscliv2
curl -sLo "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf ./awscliv2.zip ./aws

# setup tab completion
/usr/local/bin/kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null
/usr/local/bin/eksctl completion bash | sudo tee /etc/bash_completion.d/eksctl >/dev/null

echo 'source /usr/share/bash-completion/bash_completion' >> $HOME/.bashrc
. $HOME/.bashrc
```

Once you have everything done use `eksctl` to create an EKS cluster with the following command

```bash
eksctl create cluster --name $CLUSTER \
    --managed --enable-ssm
```

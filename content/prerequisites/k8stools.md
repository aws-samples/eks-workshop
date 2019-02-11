---
title: "Install Kubernetes Tools"
chapter: false
weight: 22
---

Amazon EKS clusters require kubectl and kubelet binaries and the aws-iam-authenticator
binary to allow IAM authentication for your Kubernetes cluster.

{{% notice tip %}}
In this workshop we will give you the commands to download the Linux
binaries. If you are running Mac OSX / Windows, please [see the official EKS docs
for the download links.](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
{{% /notice %}}

#### Create the default ~/.kube directory for storing kubectl configuration
```
mkdir -p ~/.kube
```

#### Install kubectl
```
sudo curl --silent --location -o /usr/local/bin/kubectl "https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/kubectl"
sudo chmod +x /usr/local/bin/kubectl
```

#### Install AWS IAM Authenticator
```
go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator
sudo mv ~/go/bin/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
```

#### Verify the binaries
```
kubectl version --short --client
aws-iam-authenticator help
```

#### Install JQ
```
sudo yum -y install jq
```

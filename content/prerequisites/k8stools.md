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
sudo curl --silent --location -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.13.7/bin/linux/amd64/kubectl


sudo chmod +x /usr/local/bin/kubectl
```

#### Install AWS IAM Authenticator
```
go get -u -v sigs.k8s.io/aws-iam-authenticator/cmd/aws-iam-authenticator
sudo mv ~/go/bin/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
```

#### Install JQ and envsubst
```
sudo yum -y install jq gettext
```

#### Verify the binaries are in the path and executable
```
for command in kubectl aws-iam-authenticator jq envsubst
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done
```

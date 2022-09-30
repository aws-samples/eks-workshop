---
title: "Install Kubernetes Tools"
chapter: false
weight: 15
---

Amazon EKS clusters require kubectl and kubelet binaries and the aws-cli or aws-iam-authenticator
binary to allow IAM authentication for your Kubernetes cluster.

{{% notice tip %}}
In this workshop we will give you the commands to download the Linux
binaries. If you are running Mac OSX / Windows, please [see the official EKS docs
for the download links.](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
{{% /notice %}}

#### Install kubectl

```bash
sudo curl --silent --location -o /usr/local/bin/kubectl \
   https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.5/2022-01-21/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl
```

#### Update awscli

Upgrade AWS CLI according to guidance in [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html).

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### Install jq, envsubst (from GNU gettext utilities) and bash-completion

```bash
sudo yum -y install jq gettext bash-completion moreutils
```

#### Install yq for yaml processing

```bash
echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc
```

#### Verify the binaries are in the path and executable

```bash
for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done
```

#### Enable kubectl bash_completion

```bash
kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
```

#### set the AWS Load Balancer Controller version

```bash
echo 'export LBC_VERSION="v2.4.1"' >>  ~/.bash_profile
echo 'export LBC_CHART_VERSION="1.4.1"' >>  ~/.bash_profile
.  ~/.bash_profile
```

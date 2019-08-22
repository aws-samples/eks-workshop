---
title: "Install"
date: 2019-08-22T00:00:00-08:00
weight: 10
draft: false
---

### Install Kubeflow on Amazon EKS

Download 0.6.1+ release of `kfctl`. This binary will allow you to install Kubeflow on Amazon EKS:

```
curl -O https://github.com/kubeflow/kubeflow/releases/download/v0.6.1/kfctl_v0.6.1_darwin.tar.gz
tar xzvf kfctl_v0.6.1_darwin.tar.gz
mv kfctl /usr/local/bin/kfctl
```

Download the configuration file:

```
export CONFIG="/tmp/kfctl_aws.yaml"
curl -o ${CONFIG} https://raw.githubusercontent.com/kubeflow/kubeflow/v0.6.1/bootstrap/config/kfctl_aws.yaml
```

Customize this configuration file for Amazon EKS cluster name, AWS region, and IAM role for your worker nodes:

```
export AWS_CLUSTER_NAME=<YOUR EKS CLUSTER NAME>
export KFAPP=${AWS_CLUSTER_NAME}
```



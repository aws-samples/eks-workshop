---
title: "Install"
date: 2019-08-22T00:00:00-08:00
weight: 10
draft: false
---

In this chapter, we will install Kubeflow on Amazon EKS cluster. The cluster creation steps are outlined in [Launch EKS](/eksctl/launcheks/#create-eks-cluster-1) chapter.

### Install Kubeflow on Amazon EKS

Download 0.6.1+ release of `kfctl`. This binary will allow you to install Kubeflow on Amazon EKS:

```
curl --silent --location "https://github.com/kubeflow/kubeflow/releases/download/v0.6.1/kfctl_v0.6.1_$(uname -s).tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin
```

Download Kubeflow configuration file:

```
CONFIG=~/environment/kfctl_aws.yaml
curl -Lo ${CONFIG} https://raw.githubusercontent.com/kubeflow/kubeflow/v0.6.1/bootstrap/config/kfctl_aws.yaml
```

Customize this configuration file for AWS region and IAM role for your worker nodes:

```
sed -i "s@eksctl-kubeflow-aws-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@$ROLE_NAME@" ${CONFIG}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG}
```

Until https://github.com/kubeflow/kubeflow/issues/3827 is fixed, install `aws-iam-authenticator`:

```
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin
```

Set Kubeflow application name:

```
export AWS_CLUSTER_NAME=eksworkshop-eksctl
export KFAPP=${AWS_CLUSTER_NAME}
```

Initialize the cluster:

```
kfctl init ${KFAPP} --config=${CONFIG} -V
```

Create and apply AWS and Kubernetes resources in the cluster:

```
cd ${KFAPP}

kfctl generate all -V
kfctl apply all -V
```

Wait for all pods to be in `Running` state (this can take a few minutes):

```
kubectl get pods -n kubeflow
```

Validate that GPUs are available:

```
kubectl get nodes "-o=custom-columns=NAME:.metadata.name,MEMORY:.status.allocatable.memory,CPU:.status.allocatable.cpu,GPU:.status.allocatable.nvidia\.com/gpu"
NAME                                          MEMORY        CPU   GPU
ip-192-168-54-93.us-east-2.compute.internal   251641628Ki   32    4
ip-192-168-68-80.us-east-2.compute.internal   251641628Ki   32    4
```

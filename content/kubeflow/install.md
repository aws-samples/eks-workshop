---
title: "Install"
date: 2019-08-22T00:00:00-08:00
weight: 10
draft: false
---

In this chapter, we will install Kubeflow on Amazon EKS cluster. If you don't have an EKS cluster, please follow instructions from [getting started guide] (/prerequisites) and then launch your EKS cluster using [eksctl](/eksctl) chapter

### Install Kubeflow on Amazon EKS

Download 0.7 RC6 release of `kfctl`. This binary will allow you to install Kubeflow on Amazon EKS:

```
curl --silent --location "https://github.com/kubeflow/kubeflow/releases/download/v0.7.0-rc.6/kfctl_v0.7.0-rc.5-7-gc66ebff3_linux.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin
```

Download Kubeflow configuration file:

```
CONFIG=~/environment/kfctl_aws.yaml
curl -Lo ${CONFIG} https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_aws.0.7.0.yaml
```
#### Customize your configuration

Set an environment variable for your AWS cluster name, and set the name of the Kubeflow deployment to the same as the cluster name.

```
export AWS_CLUSTER_NAME=eksworkshop-eksctl
export KF_NAME=${AWS_CLUSTER_NAME}
```
Set the path to the base directory where you want to store Kubeflow deployments. Then set the Kubeflow application directory for this deployment.

```
export BASE_DIR=~/environment
export KF_DIR=${BASE_DIR}/${KF_NAME}
```
Until https://github.com/kubeflow/kubeflow/issues/3827 is fixed, install `aws-iam-authenticator`:

```
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin
```

Run **kfctl build** command to set up your configuraiton

```
mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl build -V -f ${CONFIG_URI}
```
Set an environment variable pointing to your local configuration file

```
export CONFIG_FILE=${KF_DIR}/kfctl_aws.0.7.0.yaml
```

Replace EKS Cluster Name, AWS Region and IAM Roles in your $(CONFIG_FILE)

```
sed -i -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}
sed -i "s@eksctl-eksworkshop-eksctl-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@$ROLE_NAME@" ${CONFIG_FILE}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}
```
#### Deploy Kubeflow

Apply configuration and deploy Kubeflow on your cluster:

```
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_FILE}
```

Wait for all pods to be in **Running** state (this can take a few minutes):

```
kubectl get pods -n kubeflow
```

Validate that GPUs are available:

```
kubectl get nodes "-o=custom-columns=NAME:.metadata.name,MEMORY:.status.allocatable.memory,CPU:.status.allocatable.cpu,GPU:.status.allocatable.nvidia\.com/gpu"
```
You should see number of GPU's available in your worker nodes
```
NAME                                          MEMORY        CPU   GPU
ip-192-168-54-93.us-east-2.compute.internal   251641628Ki   32    4
ip-192-168-68-80.us-east-2.compute.internal   251641628Ki   32    4
```

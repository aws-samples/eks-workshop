---
title: "Install"
date: 2019-08-22T00:00:00-08:00
weight: 10
draft: false
---

### Install Kubeflow on Amazon EKS

Download 0.6.1+ release of `kfctl`. This binary will allow you to install Kubeflow on Amazon EKS:

```
curl -Lo kfctl.tar.gz https://github.com/kubeflow/kubeflow/releases/download/v0.6.1/kfctl_v0.6.1_$(uname -s).tar.gz
tar xzvf kfctl.tar.gz
sudo mv kfctl /usr/local/bin/kfctl
```

Download the configuration file:

```
CONFIG=~/environment/kfctl_aws.yaml
curl -Lo ${CONFIG} https://raw.githubusercontent.com/kubeflow/kubeflow/v0.6.1/bootstrap/config/kfctl_aws.yaml
```

Customize this configuration file for AWS region and IAM role for your worker nodes:

```
sed -i "s@eksctl-kubeflow-aws-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@$ROLE_NAME@" ${CONFIG}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG}
```

Set Kubeflow application name:

```
export AWS_CLUSTER_NAME=eksworkshop-eksctl
export KFAPP=${AWS_CLUSTER_NAME}
```

Initialize the cluster:

```
kfctl init ${KFAPP} --config=${CONFIG} -V
cd ${KFAPP}

kfctl generate all -V
kfctl apply all -V
```

Wait for all pods to be `Running` state:

```
kubectl -n kubeflow get all
```

Get Kubeflow service endpoint:

```
kubectl get ingress -n istio-system -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

Access the endpoint to see Kubeflow dashboard:

![dashboard](/images/kubeflow/dashboard-welcome.png)

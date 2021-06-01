---
title: "Configure CNI"
date: 2019-02-13T01:12:49-05:00
weight: 30
---

Before we start making changes to VPC CNI, let's make sure we are using latest CNI version

Run this command to find CNI version

```
kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2
```
Here is a sample response
{{< output >}}
amazon-k8s-cni:1.6.1
{{< /output >}}
Upgrade to the latest v1.7 config if you have an older version:
```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.7/config/v1.7/aws-k8s-cni.yaml
```
Wait until all the pods are recycled. You can check the status of pods by using this command
```
kubectl get pods -n kube-system -w
```
### Configure Custom networking

Edit aws-node DaemonSet and add AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG environment variable to the node container spec and set it to true

{{% notice note %}}
You only need to set one environment variable in the CNI daemonset configuration:
{{% /notice %}}
```
kubectl set env ds aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
```
```
kubectl describe daemonset aws-node -n kube-system | grep -A5 Environment
```
{{< output >}}
    Environment:
      DISABLE_TCP_EARLY_DEMUX:  false
    Mounts:
      /host/opt/cni/bin from cni-bin-dir (rw)
  Containers:
   aws-node:
--
    Environment:
      ADDITIONAL_ENI_TAGS:                 {}
      AWS_VPC_CNI_NODE_PORT_SUPPORT:       true
      AWS_VPC_ENI_MTU:                     9001
      AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER:  false
      AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG:  true
...
{{< /output >}}

Add the **ENIConfig** label for identifying your worker nodes:
```
kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone
```

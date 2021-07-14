---
title: "Configure CNI"
date: 2021-06-13T16:34:28+0000
weight: 30
---

Before we start making changes to VPC CNI, let's make sure we are using latest CNI version

Run this command to find CNI version

```
kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2
```
Here is a sample response
{{< output >}}
amazon-k8s-cni-init:v1.7.5-eksbuild.1
amazon-k8s-cni:v1.7.5-eksbuild.1
{{< /output >}}

### Configure Custom networking

Edit aws-node DaemonSet and add AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG environment variable to the node container spec and set it to true

Note: You only need to set one environment variable in the CNI daemonset configuration:
```
kubectl set env ds aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
```
```
kubectl describe daemonset aws-node -n kube-system | grep -A5 Environment
```
{{< output >}}
    Environment:
      AWS_VPC_K8S_CNI_LOGLEVEL:  	  DEBUG
      AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG: true
      MY_NODE_NAME:               	  (v1:spec.nodeName)
...
{{< /output >}}

Terminate worker nodes so that Autoscaling launches newer nodes that come bootstrapped with custom network config

{{% notice warning %}}
Use caution before you run the next command because it terminates all worker nodes including running pods in your workshop
{{% /notice %}}

```
INSTANCE_IDS=(`aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=eksworkshop*" --output text` )
for i in "${INSTANCE_IDS[@]}"
do
	echo "Terminating EC2 instance $i ..."
	aws ec2 terminate-instances --instance-ids $i
done
```

#### Additional notes on 'maxPodsPerNode'
Enabling a custom network effectively removes an available network interface (and all of its available IP addresses for pods) from each node that uses it. The primary network interface for the node is not used for pod placement when a custom network is enabled. Determine the maximum number of pods that can be scheduled on each node using the following formula.

{{< output >}}
 maxPodsPerNode = (number of interfaces - 1) * (max IPv4 addresses per interface - 1) + 2
 
 For example, use the following value for t3.small
 maxPodsPerNode = (3 - 1) * (4 - 1) + 2 = 8
{{< /output >}}
 
 In your production setup, replace your existing nodegroup with a new nodegroup and apply the value of maxPodsPerNode option. For simplicity, this workshop continues with the existing nodegroup without custom maxPodsPerNode value.

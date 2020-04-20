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
amazon-k8s-cni:1.5.7
{{< /output >}}
Upgrade to the latest v1.5 config if you have an older version:
```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.5/aws-k8s-cni.yaml
```
Wait until all the pods are recycled. You can check the status of pods by using this command
```
kubectl get pods -n kube-system -w
```
### Configure Custom networking

Edit aws-node configmap and add AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG environment variable to the node container spec and set it to true

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

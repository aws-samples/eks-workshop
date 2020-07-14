---
title: "Cleanup"
date: 2019-03-02T16:47:38-05:00
weight: 60
---
Let's cleanup this tutorial

```
kubectl delete deployments --all
```
Edit aws-node configmap and comment AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG and its value
```
kubectl edit daemonset -n kube-system aws-node
```
```
...
    spec:
      containers:
      - env:
        #- name: AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG
        #  value: "true"
        - name: AWS_VPC_K8S_CNI_LOGLEVEL
          value: DEBUG
        - name: MY_NODE_NAME
...
```
Delete custom resource objects from ENIConfig CRD
```
kubectl delete eniconfig/group1-pod-netconfig
kubectl delete eniconfig/group2-pod-netconfig
kubectl delete eniconfig/group3-pod-netconfig
```
Terminate EC2 instances so that fresh instances are launched with default CNI configuration

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
Delete secondary CIDR from your VPC
```
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=eksctl-eksworkshop* | jq -r '.Vpcs[].VpcId')
ASSOCIATION_ID=$(aws ec2 describe-vpcs --vpc-id $VPC_ID | jq -r '.Vpcs[].CidrBlockAssociationSet[] | select(.CidrBlock == "100.64.0.0/16") | .AssociationId')
aws ec2 delete-subnet --subnet-id $CGNAT_SNET1
aws ec2 delete-subnet --subnet-id $CGNAT_SNET2
aws ec2 delete-subnet --subnet-id $CGNAT_SNET3
aws ec2 disassociate-vpc-cidr-block --association-id $ASSOCIATION_ID
```

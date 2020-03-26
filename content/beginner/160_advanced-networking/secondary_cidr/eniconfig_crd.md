---
title: "Create CRDs"
date: 2019-03-02T12:47:43-05:00
weight: 40
---

### Create custom resources for ENIConfig CRD
As next step, we will add custom resources to ENIConfig custom resource definition (CRD). CRD's are extensions of Kubernetes API that stores collection of API objects of certain kind. In this case, we will store VPC Subnet and SecurityGroup configuration information in these CRD's so that Worker nodes can access them to configure VPC CNI plugin.

You should have ENIConfig CRD already installed with latest CNI version (1.3+). You can check if its installed by running this command.
```
kubectl get crd
```
You should see response similar to this
{{< output >}}
NAME                               CREATED AT
eniconfigs.crd.k8s.amazonaws.com   2019-03-07T20:06:48Z
{{< /output >}}
If you don't have ENIConfig installed, you can install it by using this command
```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.3/aws-k8s-cni.yaml
```
Create custom resources for each subnet by replacing **Subnet** and **SecurityGroup IDs**. Since we created three secondary subnets, we need create three custom resources.

Here is the template for custom resource. Notice the values for Subnet ID and SecurityGroup ID needs to be replaced with appropriate values
```
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: group1-pod-netconfig
spec:
 subnet: $SUBNETID1
 securityGroups:
 - $SECURITYGROUPID1
 - $SECURITYGROUPID2
```
Check the AZ's and Subnet IDs for these subnets. Make note of AZ info as you will need this when you apply annotation to Worker nodes using custom network config
```
aws ec2 describe-subnets  --filters "Name=cidr-block,Values=100.64.*" --query 'Subnets[*].[CidrBlock,SubnetId,AvailabilityZone]' --output table
```
{{< output >}}
--------------------------------------------------------------
|                       DescribeSubnets                      |
+-----------------+----------------------------+-------------+
|  100.64.32.0/19 |  subnet-07dab05836e4abe91  |  us-east-2a |
|  100.64.64.0/19 |  subnet-0692cd08cc4df9b6a  |  us-east-2c |
|  100.64.0.0/19  |  subnet-04f960ffc8be6865c  |  us-east-2b |
+-----------------+----------------------------+-------------+
{{< /output >}}
Check your Worker Node SecurityGroup
```
INSTANCE_IDS=(`aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=eksworkshop*" --output text`)
for i in "${INSTANCE_IDS[@]}"
do
  echo "SecurityGroup for EC2 instance $i ..."
  aws ec2 describe-instances --instance-ids $i | jq -r '.Reservations[].Instances[].SecurityGroups[].GroupId'
done  
```
{{< output >}}
SecurityGroup for EC2 instance i-03ea1a083c924cd78 ...
sg-070d03008bda531ad
sg-06e5cab8e5d6f16ef
SecurityGroup for EC2 instance i-0a635aed890c7cc3e ...
sg-070d03008bda531ad
sg-06e5cab8e5d6f16ef
SecurityGroup for EC2 instance i-048e5ec8815e5ea8a ...
sg-070d03008bda531ad
sg-06e5cab8e5d6f16ef
{{< /output >}}
Create custom resource **group1-pod-netconfig.yaml** for first subnet (100.64.0.0/19). Replace the SubnetId and SecuritGroupIds with the values from above. Here is how it looks with the configuration values for my environment

Note: We are using same SecurityGroup for pods as your Worker Nodes but you can change these and use custom SecurityGroups for your Pod Networking

```
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: group1-pod-netconfig
spec:
 subnet: subnet-04f960ffc8be6865c
 securityGroups:
 - sg-070d03008bda531ad
 - sg-06e5cab8e5d6f16ef
```
Create custom resource **group2-pod-netconfig.yaml** for second subnet (100.64.32.0/19). Replace the SubnetId and SecuritGroupIds as above.

Similarly, create custom resource **group3-pod-netconfig.yaml** for third subnet (100.64.64.0/19). Replace the SubnetId and SecuritGroupIds as above.

Check the instance details using this command as you will need AZ info when you apply annotation to Worker nodes using custom network config
```
aws ec2 describe-instances --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=eksworkshop*" --query 'Reservations[*].Instances[*].[PrivateDnsName,Tags[?Key==`eks:nodegroup-name`].Value|[0],Placement.AvailabilityZone,PrivateIpAddress,PublicIpAddress]' --output table  
```
{{< output >}}
------------------------------------------------------------------------------------------------------------------------------------------
|                                                            DescribeInstances                                                           |
+-----------------------------------------------+---------------------------------------+-------------+-----------------+----------------+
|  ip-192-168-9-228.us-east-2.compute.internal  |  eksworkshop-eksctl-ng-475d4bc8-Node  |  us-east-2c |  192.168.9.228  |  18.191.57.131 |
|  ip-192-168-71-211.us-east-2.compute.internal |  eksworkshop-eksctl-ng-475d4bc8-Node  |  us-east-2a |  192.168.71.211 |  18.221.77.249 |
|  ip-192-168-33-135.us-east-2.compute.internal |  eksworkshop-eksctl-ng-475d4bc8-Node  |  us-east-2b |  192.168.33.135 |  13.59.167.90  |
+-----------------------------------------------+---------------------------------------+-------------+-----------------+----------------+
{{< /output >}}

Apply the CRD's
```
kubectl apply -f group1-pod-netconfig.yaml
kubectl apply -f group2-pod-netconfig.yaml
kubectl apply -f group3-pod-netconfig.yaml
```
As last step, we will annotate nodes with custom network configs.

{{% notice warning %}}
Be sure to annotate the instance with config that matches correct AZ. For ex, in my environment instance ip-192-168-33-135.us-east-2.compute.internal is in us-east-2b. So, I will apply **group1-pod-netconfig.yaml** to this instance. Similarly, I will apply **group2-pod-netconfig.yaml** to ip-192-168-71-211.us-east-2.compute.internal and **group3-pod-netconfig.yaml** to ip-192-168-9-228.us-east-2.compute.internal
{{% /notice %}}

```
kubectl annotate node <nodename>.<region>.compute.internal k8s.amazonaws.com/eniConfig=group1-pod-netconfig
```
As an example, here is what I would run in my environment
{{< output >}}
kubectl annotate node ip-192-168-33-135.us-east-2.compute.internal k8s.amazonaws.com/eniConfig=group1-pod-netconfig
{{< /output >}}
You should now see secondary IP address from extended CIDR assigned to annotated nodes.

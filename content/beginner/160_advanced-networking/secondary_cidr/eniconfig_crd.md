---
title: "Create CRDs"
date: 2019-03-02T12:47:43-05:00
weight: 40
---

### Create custom resources for ENIConfig CRD
As next step, we will add custom resources to ENIConfig custom resource definition (CRD). CRDs are extensions of Kubernetes API that stores collection of API objects of certain kind. In this case, we will store VPC Subnet and SecurityGroup configuration information in these CRDs so that Worker nodes can access them to configure VPC CNI plugin.

You should have ENIConfig CRD already installed with latest CNI version (1.3+). You can check if its installed by running this command.
```
kubectl get crd | grep eni
```
You should see a response similar to this
{{< output >}}
eniconfigs.crd.k8s.amazonaws.com   2021-04-28T00:35:54Z
{{< /output >}}
If you don't have ENIConfig installed, you can install it by using this command
```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.7/config/v1.7/aws-k8s-cni.yaml
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
Compare the subnet-ID's stored in environment variables `CGNAT_SNET1`, `CGNAT_SNET2`, `CGNAT_SNET3` against the command below:
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

Create `ENIConfig` custom resources for all Availability Zones & Subnets:

```
cat <<EOF  | kubectl apply -f -
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: $AZ1
spec:
  subnet: $CGNAT_SNET1
EOF

cat <<EOF | kubectl apply -f -
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: $AZ2
spec:
  subnet: $CGNAT_SNET2
EOF

cat <<EOF | kubectl apply -f -
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: $AZ3
spec:
  subnet: $CGNAT_SNET3
EOF
```
{{% notice info %}}
The ENIConfig should match the Availability Zone of your worker nodes.
{{% /notice %}}

{{% notice note %}}
Since we didn't specify a security group, the default security group for the VPC is assigned to secondary ENI's. If you want to assign different security groups to individual pods, then you can use [Security groups for pods](https://www.eksworkshop.com/beginner/115_sg-per-pod/). Security groups for pods create additional network interfaces that can each be assigned a unique security group. Security groups for pods can be used with or without custom networking.
{{% /notice %}}

Terminate worker nodes so that Autoscaling launches newer nodes that come bootstrapped with custom network config

{{% notice warning %}}
Use caution before you run the next command because it terminates all worker nodes including running pods in your workshop
{{% /notice %}}

```
INSTANCE_IDS=(`aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag-key,Values=alpha.eksctl.io/cluster-name" "Name=tag-value,Values=eksworkshop-eksctl*" --output text` )
for i in "${INSTANCE_IDS[@]}"
do
	echo "Terminating EC2 instance $i ..."
	aws ec2 terminate-instances --instance-ids $i
done
```
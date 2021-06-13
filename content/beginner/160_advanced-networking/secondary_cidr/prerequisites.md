---
title: "Prerequisites"
date: 2021-06-13T16:34:28+0000
weight: 20
---

Before we configure EKS, we need to enable secondary CIDR blocks in your VPC and make sure they have proper tags and route table configurations

### Add secondary CIDRs to your VPC

{{% notice info %}}
There are restrictions on the range of secondary CIDRs you can use to extend your VPC. For more info, see [IPv4 CIDR Block Association Restrictions](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#add-cidr-block-restrictions)
{{% /notice %}}

You can use below commands to add 100.64.0.0/16 to your EKS cluster VPC. Please note to change the Values parameter to EKS cluster name if you used different name than eksctl-eksworkshop
```
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=eksctl-eksworkshop* --query 'Vpcs[].VpcId' --output text)

aws ec2 associate-vpc-cidr-block --vpc-id $VPC_ID --cidr-block 100.64.0.0/16
```
Next step is to create subnets. Before we do this step, let's check how many subnets we are consuming. You can run this command to see EC2 instance and AZ details

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

I have 3 instances and using 3 subnets in my environment. For simplicity, we will use the same AZ's and create 3 secondary CIDR subnets but you can certainly customize according to your networking requirements.
```
export POD_AZS=($(aws ec2 describe-instances --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=eksworkshop*" --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone]' --output text | sort | uniq))

echo ${POD_AZS[@]}

CGNAT_SNET1=$(aws ec2 create-subnet --cidr-block 100.64.0.0/19 --vpc-id $VPC_ID --availability-zone ${POD_AZS[0]} --query 'Subnet.SubnetId' --output text)
CGNAT_SNET2=$(aws ec2 create-subnet --cidr-block 100.64.32.0/19 --vpc-id $VPC_ID --availability-zone ${POD_AZS[1]} --query 'Subnet.SubnetId' --output text)
CGNAT_SNET3=$(aws ec2 create-subnet --cidr-block 100.64.64.0/19 --vpc-id $VPC_ID --availability-zone ${POD_AZS[2]} --query 'Subnet.SubnetId' --output text)

unset POD_AZS
```
As next step, we need to associate three new subnets into a route table. Again for simplicity, we chose to add new subnets to the Public route table that has connectivity to Internet Gateway
```
SNET1=$(aws ec2 describe-subnets --filters Name=cidr-block,Values=192.168.0.0/19 --query 'Subnets[].SubnetId' --output text)
RTASSOC_ID=$(aws ec2 describe-route-tables --filters Name=association.subnet-id,Values=$SNET1 --query 'RouteTables[].RouteTableId' --output text)
aws ec2 associate-route-table --route-table-id $RTASSOC_ID --subnet-id $CGNAT_SNET1
aws ec2 associate-route-table --route-table-id $RTASSOC_ID --subnet-id $CGNAT_SNET2
aws ec2 associate-route-table --route-table-id $RTASSOC_ID --subnet-id $CGNAT_SNET3
```

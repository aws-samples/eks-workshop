---
title: "Configure EKS cluster"
weight: 40
---

We created an EKS cluster cluster with a managed node group and OIDC.
For Postgres persistent storage we're going to use a host path for the sake of this workshop but it would be advised to use [Amazon Elastic File System (EFS)](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html) because it's a regional storage service.
If the Postgres pod moves availability zones data will still be available.
If you'd like to do it manually you can follow the [EFS workshop here](https://www.eksworkshop.com/beginner/190_efs/).


To let traffic cross between EKS and Cloud9 we need to create a VPC peering between our Cloud9 instance and our EKS cluster as shown.
![configure eks cluster vpc-peering](/images/migrate_to_eks/configure-eks-cluster-vpc-peering.png)


```bash
export EKS_VPC=$(aws eks describe-cluster \
    --name ${CLUSTER} \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)

export PEERING_ID=$(aws ec2 create-vpc-peering-connection \
    --vpc-id $VPC --peer-vpc-id $EKS_VPC \
    --query 'VpcPeeringConnection.VpcPeeringConnectionId' \
    --output text)

aws ec2 accept-vpc-peering-connection \
    --vpc-peering-connection-id $PEERING_ID

aws ec2 modify-vpc-peering-connection-options \
    --vpc-peering-connection-id $PEERING_ID \
    --requester-peering-connection-options '{"AllowDnsResolutionFromRemoteVpc":true}' \
    --accepter-peering-connection-options '{"AllowDnsResolutionFromRemoteVpc":true}'
```

Finally create routes in both VPCs to route traffic

```bash
export CIDR_BLOCK_1=$(aws ec2 describe-vpc-peering-connections \
    --query "VpcPeeringConnections[?VpcPeeringConnectionId=='$PEERING_ID'].AccepterVpcInfo.CidrBlock" \
    --output text)

export CIDR_BLOCK_2=$(aws ec2 describe-vpc-peering-connections \
    --query "VpcPeeringConnections[?VpcPeeringConnectionId=='$PEERING_ID'].RequesterVpcInfo.CidrBlock" \
    --output text)

export EKS_RT=$(aws cloudformation list-stack-resources \
    --query "StackResourceSummaries[?LogicalResourceId=='PublicRouteTable'].PhysicalResourceId" \
    --stack-name eksctl-${CLUSTER}-cluster \
    --output text)

export RT=$(aws ec2 describe-route-tables \
    --filter "Name=vpc-id,Values=${VPC}" \
    --query 'RouteTables[0].RouteTableId' \
    --output text)

aws ec2 create-route \
    --route-table-id $EKS_RT \
    --destination-cidr-block $CIDR_BLOCK_2 \
    --vpc-peering-connection-id $PEERING_ID

aws ec2 create-route \
    --route-table-id $RT \
    --destination-cidr-block $CIDR_BLOCK_1 \
    --vpc-peering-connection-id $PEERING_ID
```

Now that traffic will route between our clusters we can deploy our application to the EKS cluster.
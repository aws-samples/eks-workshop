---
title: "Prerequisite"
date: 2020-11-26T15:59:47-05:00
draft: false
chapter: false
weight: 10
---




### Create the RDS database

# Get the VPC and EKS SGs ID

```bash
# get Cloud 9 security group
export C9_SG=$(curl -s http://169.254.169.254/latest/meta-data/security-groups)

# get eks cluster VPC ID
export VPC_ID=$(aws eks describe-cluster \
    --name eksworkshop-eksctl \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)

export K8S_NODE_SGS=$(aws ec2 describe-security-groups \
    --filters Name=tag:aws:cloudformation:logical-id,Values=ClusterSharedNodeSecurityGroup Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" \
    --output text)

export CONTROL_PLANE_SG=$(aws ec2 describe-security-groups \
    --filters Name=tag:aws:cloudformation:logical-id,Values=ControlPlaneSecurityGroup Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" \
    --output text)
```

# get EKS cluster private subnets ID

```bash
export PUBLIC_SUBNETS_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-eksworkshop-eksctl-cluster/SubnetPublic*" \
    --query 'Subnets[*].SubnetId' \
    --output json | jq -c .)

# create db subnet group using the private subnets ID
aws rds create-db-subnet-group \
    --db-subnet-group-name rds-eksworkshop \
    --db-subnet-group-description rds-eksworkshop \
    --subnet-ids ${PUBLIC_SUBNETS_ID}

# create RDS Security group
aws ec2 create-security-group \
    --description 'RDS SG' \
    --group-name 'RDS_SG' \
    --vpc-id ${VPC_ID}

# get RDS SG ID
export RDS_SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=RDS_SG Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" --output text)


# create GREEN POD security group
aws ec2 create-security-group \
    --description 'POD SG' \
    --group-name 'POD_SG' \
    --vpc-id ${VPC_ID}

export POD_SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=POD_SG Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" --output text)

#configure GREEN POD and Control Plane
#allow POD SG to connec to 
# get POD SG ID

# create RDS Postgresql instance
aws rds create-db-instance \
    --db-instance-identifier rds-eksworkshop \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --db-subnet-group-name rds-eksworkshop \
    --vpc-security-group-ids $RDS_SG \
    --master-username eksworkshop \
    --publicly-accessible \
    --master-user-password secredfadfadfadfasdft99 \
    --allocated-storage 20


# Allow pod SG to connect to the RDS
aws ec2 authorize-security-group-ingress \
    --group-id ${RDS_SG} \
    --protocol tcp \
    --port 5432 \
    --source-group ${POD_SG}
```


### Configure the EKS Cluster

### create EKS SG group

### ECR

### build  image

### secrets
---
title: "RDS creation"
date: 2020-12-02T21:00:37-05:00
draft: false
weight: 20
tags:
  - beginner
---

Now that our security groups are ready let's create our Amazon RDS for PostgreSQL database.

We first need to create a [DB subnet groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.Subnets). We will use the same subnets as our EKS cluster.

```bash
export PUBLIC_SUBNETS_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-eksworkshop-eksctl-cluster/SubnetPublic*" \
    --query 'Subnets[*].SubnetId' \
    --output json | jq -c .)

# create a db subnet group
aws rds create-db-subnet-group \
    --db-subnet-group-name rds-eksworkshop \
    --db-subnet-group-description rds-eksworkshop \
    --subnet-ids ${PUBLIC_SUBNETS_ID}
```

We can now create our database.

```bash
# get RDS SG ID
export RDS_SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=RDS_SG Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" --output text)

# generate a password for RDS
export RDS_PASSWORD="$(date | md5sum  |cut -f1 -d' ')"
echo ${RDS_PASSWORD}  > ~/environment/sg-per-pod/rds_password


# create RDS Postgresql instance
aws rds create-db-instance \
    --db-instance-identifier rds-eksworkshop \
    --db-name eksworkshop \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --db-subnet-group-name rds-eksworkshop \
    --vpc-security-group-ids $RDS_SG \
    --master-username eksworkshop \
    --publicly-accessible \
    --master-user-password ${RDS_PASSWORD} \
    --backup-retention-period 0 \
    --allocated-storage 20
```

{{% notice info %}}
It will take up to 4 minutes for the database to be created.
{{% /notice %}}

You can verify if it's available using this command.

```bash
aws rds describe-db-instances \
    --db-instance-identifier rds-eksworkshop \
    --query "DBInstances[].DBInstanceStatus" \
    --output text
```

Expected output

{{< output >}}
available
{{< /output >}}

Now that the database is available, let's get our database Endpoint.

```bash
# get RDS endpoint
export RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier rds-eksworkshop \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

echo "RDS endpoint: ${RDS_ENDPOINT}"
```

Our last step is to create some content in the database.

```bash
sudo yum install -y postgresql

cd sg-per-pod

cat << EoF > ~/environment/sg-per-pod/pgsql.sql
CREATE TABLE welcome (column1 TEXT);
insert into welcome values ('--------------------------');
insert into welcome values ('Welcome to the eksworkshop');
insert into welcome values ('--------------------------');
EoF

export RDS_PASSWORD=$(cat ~/environment/sg-per-pod/rds_password)

psql postgresql://eksworkshop:${RDS_PASSWORD}@${RDS_ENDPOINT}:5432/eksworkshop \
    -f ~/environment/sg-per-pod/pgsql.sql
```

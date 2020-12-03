---
title: "Cleanup"
date: 2020-12-02T16:04:30-05:00
draft: false
weight: 90
tags:
  - beginner
---

```bash
export VPC_ID=$(aws eks describe-cluster \
    --name eksworkshop-eksctl \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)
export RDS_SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=RDS_SG Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" --output text)
export POD_SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=POD_SG Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" --output text)
export C9_IP=$(curl -s ifconfig.me.)
export NODE_GROUP_SG=$(aws ec2 describe-security-groups \
    --filters Name=tag:Name,Values=eks-cluster-sg-eksworkshop-eksctl-* Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" \
    --output text)

# uninstall the RPM package
sudo yum erase -y postgresql

# delete database
aws rds delete-db-instance \
    --db-instance-identifier rds-eksworkshop \
    --delete-automated-backups \
    --skip-final-snapshot

# delete kubernetes element
kubectl -n sg-per-pod delete -f ~/environment/sg-per-pod/green-pod.yaml
kubectl -n sg-per-pod delete -f ~/environment/sg-per-pod/red-pod.yaml
kubectl -n sg-per-pod delete -f ~/environment/sg-per-pod/sg-policy.yaml
kubectl -n sg-per-pod delete secret rds

kubectl delete ns sg-per-pod

# disable ENI trunking
kubectl -n kube-system set env daemonset aws-node ENABLE_POD_ENI=false
kubectl -n kube-system rollout status ds aws-node

# remove the trunk label
kubectl label node  --all 'vpc.amazonaws.com/has-trunk-attached'-

# detach IAM policy
aws iam detach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController \
    --role-name ${ROLE_NAME}

# remove security group rules
aws ec2 revoke-security-group-ingress \
    --group-id ${RDS_SG} \
    --protocol tcp \
    --port 5432 \
    --source-group ${POD_SG}

aws ec2 revoke-security-group-ingress \
    --group-id ${RDS_SG} \
    --protocol tcp \
    --port 5432 \
    --cidr ${C9_IP}/32

aws ec2 revoke-security-group-ingress \
    --group-id ${NODE_GROUP_SG} \
    --protocol tcp \
    --port 53 \
    --source-group ${POD_SG}

aws ec2 revoke-security-group-ingress \
    --group-id ${NODE_GROUP_SG} \
    --protocol udp \
    --port 53 \
    --source-group ${POD_SG}

# delete POD SG
aws ec2 delete-security-group \
    --group-id ${POD_SG}
cd ~/environment

rm -rf sg-per-pod
```

Verify that RDS instance has been deleted

```bash
aws rds describe-db-instances \
    --db-instance-identifier rds-eksworkshop \
    --query "DBInstances[].DBInstanceStatus" \
    --output text
```

Excepted output

{{< output >}}
An error occurred (DBInstanceNotFound) when calling the DescribeDBInstances operation: DBInstance rds-eksworkshop not found.
{{< /output >}}

```bash
# delete RDS SG
aws ec2 delete-security-group \
    --group-id ${RDS_SG}

## delete db-group
aws rds delete-db-subnet-group \
    --db-subnet-group-name rds-eksworkshop
```

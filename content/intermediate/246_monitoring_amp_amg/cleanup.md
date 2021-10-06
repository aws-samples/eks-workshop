---
title: "Cleanup"
date: 2021-05-047T08:30:11-07:00
weight: 80
draft: false
---

Congratulations on completing the Monitoring using Amazon Managed Service for Prometheus / Grafana module.

Please cleanup your environment before going to a new one:

Cleanup Helm environment:
```
helm uninstall prometheus-for-amp -n prometheus
kubectl delete ns prometheus
```

Delete IAM ressources:
```
SERVICE_ACCOUNT_IAM_ROLE=EKS-AMP-ServiceAccount-Role
SERVICE_ACCOUNT_IAM_POLICY=AWSManagedPrometheusWriteAccessPolicy
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
SERVICE_ACCOUNT_IAM_POLICY_ARN=arn:aws:iam::$AWS_ACCOUNT_ID:policy/$SERVICE_ACCOUNT_IAM_POLICY
aws iam detach-role-policy --role-name $SERVICE_ACCOUNT_IAM_ROLE --policy-arn $SERVICE_ACCOUNT_IAM_POLICY_ARN
aws iam  delete-role --role-name $SERVICE_ACCOUNT_IAM_ROLE
```

Cleanup AMP Workspace:
```
aws amp delete-workspace --workspace-id $WORKSPACE_ID
```

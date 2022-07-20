---
title: "Cleanup resources"
weight: 70
---

Delete EKS resources

```bash
kubectl delete svc/counter svc/postgres deploy/counter statefulset/postgres
```

Delete ALB

```bash
aws elbv2 delete-listener \
    --listener-arn $ALB_LISTENER

aws elbv2 delete-load-balancer \
    --load-balancer-arn $ALB_ARN

aws elbv2 delete-target-group \
    --target-group-arn $TG_ARN
```

Delete VPC peering

```bash
aws ec2 delete-vpc-peering-connection \
    --vpc-peering-connection-id $PEERING_ID
```

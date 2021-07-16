---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

```bash

# Delete created k8s resources
kubectl delete -f fargate-ns.yaml
kubectl delete -f aws-observability-namespace.yaml

# Delete IAM policy attachment & IAM policy 
aws iam detach-role-policy \
  --policy-arn $POLICY_ARN \
  --role-name ${POD_EXECUTION_ROLE//arn:aws:iam::[0-9]*:role\//}
aws iam delete-policy --policy-arn $POLICY_ARN

# Delete log group
aws logs delete-log-group --log-group-name fluent-bit-cloudwatch
```

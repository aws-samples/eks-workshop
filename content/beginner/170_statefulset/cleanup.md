---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 40
---
```sh
# Delete the mysql namespace 
kubectl delete namespace mysql

# Detach the IAM Amazon_EBS_CSI_Driver policy from your worker node instance profile.
export EBS_CNI_POLICY_NAME="Amazon_EBS_CSI_Driver"
export EBS_CNI_POLICY_ARN=$(aws --region ${AWS_REGION} iam list-policies --query 'Policies[?PolicyName==`'${EBS_CNI_POLICY_NAME}'`].Arn' --output text)

aws iam detach-role-policy \
  --region ${AWS_REGION} \
  --policy-arn ${EBS_CNI_POLICY_ARN} \
  --role-name ${ROLE_NAME}

# Delete the IAM Amazon_EBS_CSI_Driver policy
aws iam delete-policy \
  --region ${AWS_REGION} \
  --policy-arn ${EBS_CNI_POLICY_ARN}
```
## Congratulation! You've finished the StatefulSets lab.

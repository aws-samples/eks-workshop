---
title: "Cleanup"
date: 2019-10-25T15:43:24-04:00
weight: 90
draft: false
---

### Uninstall Kubeflow

Delete IAM users, S3 bucket and Kubernetes secret
```
# delete s3user
aws iam detach-user-policy --user-name s3user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam delete-access-key --access-key-id `echo $AWS_ACCESS_KEY_ID_VALUE | base64 --decode` --user-name s3user
aws iam delete-user --user-name s3user
# delete sagemakeruser
aws iam detach-user-policy --user-name sagemakeruser --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam delete-access-key --access-key-id `echo $AWS_ACCESS_KEY_ID_VALUE | base64 --decode` --user-name sagemakeruser
aws iam delete-user --user-name sagemakeruser
# delete S3 bucket
aws s3 rb s3://$S3_BUCKET --force --region $AWS_REGION
# delete aws-secret
kubectl delete secret/aws-secret
kubectl delete secret/aws-secret -n kubeflow
```
Run these commands to uninstall Kubeflow from your EKS cluster
```
cd ${KF_DIR}
kfctl delete -V -f ${CONFIG_FILE}
```
Scale the cluster back to previous size
```
eksctl scale nodegroup --cluster eksworkshop-eksctl --name $NODEGROUP_NAME --nodes 3
```

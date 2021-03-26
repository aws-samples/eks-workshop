---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 40
---
```sh
export EBS_CSI_POLICY_NAME="Amazon_EBS_CSI_Driver"
export EBS_CSI_POLICY_ARN=$(aws --region ${AWS_REGION} iam list-policies --query 'Policies[?PolicyName==`'${EBS_CSI_POLICY_NAME}'`].Arn' --output text)

kubectl delete \
  -f ${HOME}/environment/ebs_statefulset/mysql-statefulset.yaml \
  -f ${HOME}/environment/ebs_statefulset/mysql-services.yaml \
  -f ${HOME}/environment/ebs_statefulset/mysql-configmap.yaml \
  -f ${HOME}/environment/ebs_statefulset/mysql-storageclass.yaml

# Delete the mysql namespace 
kubectl delete namespace mysql

# Uninstall the aws-ebs-csi-driver
helm -n kube-system uninstall aws-ebs-csi-driver

# Delete the service account
eksctl delete iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace kube-system \
  --name ebs-csi-controller-irsa \
  --wait

# Delete the IAM Amazon_EBS_CSI_Driver policy
aws iam delete-policy \
  --region ${AWS_REGION} \
  --policy-arn ${EBS_CSI_POLICY_ARN}

cd ${HOME}/environment
rm -rf ${HOME}/environment/ebs_statefulset
```

## Congratulation! You've finished the StatefulSets lab

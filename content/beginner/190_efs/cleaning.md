---
title: "Clean Up"
date: 2021-07-01T00:00:00-05:00
weight: 15
draft: false
---
### Cleaning up
Delete the Kubernetes resources deployed to the EKS cluster. 
```sh
export EFS_CSI_POLICY_NAME="AmazonEKS_EFS_CSI_Driver_Policy"
export EFS_CSI_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`'$EFS_CSI_POLICY_NAME'`].Arn' --output text)
export EFS_CSI_SERVICEACCOUNT_NAME="efs-csi-controller-sa"

cd ${HOME}/environment/efs

# delete sample applications
kubectl delete -f efs-reader.yaml
kubectl delete -f efs-writer.yaml
kubectl delete -f efs-pvc.yaml

# uninstall the aws-efs-csi-driver 
helm -n kube-system uninstall aws-efs-csi-driver

# Delete the service account
eksctl delete iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace kube-system \
  --name $EFS_CSI_SERVICEACCOUNT_NAME \
  --wait

# Delete the IAM Amazon_EBS_CSI_Driver policy
aws iam delete-policy \
  --region ${AWS_REGION} \
  --policy-arn ${EFS_CSI_POLICY_ARN}

cd ${HOME}/environment
rm -rf ${HOME}/environment/efs
```

Delete the mount targets associated with the EFS file system
```sh
FILE_SYSTEM_ID=$(aws efs describe-file-systems | jq --raw-output '.FileSystems[].FileSystemId')
targets=$(aws efs describe-mount-targets --file-system-id $FILE_SYSTEM_ID | jq --raw-output '.MountTargets[].MountTargetId')
for target in ${targets[@]}
do
    echo "deleting mount target " $target
    aws efs delete-mount-target --mount-target-id $target
done
```
Check the status of EFS file system to find out if the mount targets have all been deleted.
```sh
aws efs describe-file-systems --file-system-id $FILE_SYSTEM_ID
```
When the **NumberOfMountTargets** field in the JSON output reads 0, run the following command to delete the EFS file system.
```sh
aws efs delete-file-system --file-system-id $FILE_SYSTEM_ID
```
Delete the security group that is associated with the EFS file system
```sh
aws ec2 delete-security-group --group-id $MOUNT_TARGET_GROUP_ID
```

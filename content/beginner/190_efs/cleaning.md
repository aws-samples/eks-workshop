---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---
### Cleaning up
Delete the Kubernetes resources deployed to the EKS cluster. 
```
cd ~/environment/efs
kubectl delete -f efs-reader.yaml
kubectl delete -f efs-writer.yaml
kubectl delete -f efs-pvc.yaml
```
Delete the efs-csi-node daemonset from the kube-system namespace
```
kubectl delete ds efs-csi-node -n kube-system
```
Delete the mount targets associated with the EFS file system
```
FILE_SYSTEM_ID=$(aws efs describe-file-systems | jq --raw-output '.FileSystems[].FileSystemId')
targets=$(aws efs describe-mount-targets --file-system-id $FILE_SYSTEM_ID | jq --raw-output '.MountTargets[].MountTargetId')
for target in ${targets[@]}
do
    echo "deleting mount target " $target
    aws efs delete-mount-target --mount-target-id $target
done
```
Check the status of EFS file system to find out if the mount targets have all been deleted.
```
aws efs describe-file-systems --file-system-id $FILE_SYSTEM_ID
```
When the **NumberOfMountTargets** field in the JSON output reads 0, run the following command to delete the EFS file system.
```
aws efs delete-file-system --file-system-id $FILE_SYSTEM_ID
```
Delete the security group that is associated with the EFS file system
```
aws ec2 delete-security-group --group-id $MOUNT_TARGET_GROUP_ID
```

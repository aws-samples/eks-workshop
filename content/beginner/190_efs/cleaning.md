---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---

### Cleaning up
To delete the resources used in this chapter: 
```
cd ~/environment/efs
kubectl delete -f efs-reader.yaml
kubectl delete -f efs-writer.yaml
kubectl delete -f efs-pvc.yaml
kubectl delete -f efs-provisioner-deployment.yaml
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
```

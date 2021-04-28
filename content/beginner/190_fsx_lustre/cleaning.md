---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---
### Cleaning up

Once we are done, let's cleanup the resources specific to this module:

```
kubectl delete -f "https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/master/examples/kubernetes/dynamic_provisioning_s3/specs/pod.yaml"
kubectl delete -f claim.yaml
kubectl delete -f storageclass.yaml
kubectl delete -k "github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

aws s3 rm --recursive s3://$S3_LOGS_BUCKET
aws s3 rb  s3://$S3_LOGS_BUCKET

eksctl delete iamserviceaccount \
    --region $AWS_REGION \
    --name fsx-csi-controller-sa \
    --namespace kube-system \
    --cluster $CLUSTER_NAME

aws iam delete-policy \
    --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/Amazon_FSx_Lustre_CSI_Driver
```

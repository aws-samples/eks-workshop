---
title: "Cleanup"
date: 2019-03-20T13:59:44+01:00
weight: 60
draft: false
---

To cleanup, follow these steps.

```bash
kubectl delete -f ~/environment/irsa/job-s3.yaml
kubectl delete -f ~/environment/irsa/job-ec2.yaml

eksctl delete iamserviceaccount \
    --name iam-test \
    --namespace default \
    --cluster eksworkshop-eksctl \
    --wait

rm -rf ~/environment/irsa/

aws s3 rb s3://eksworkshop-$ACCOUNT_ID-$AWS_REGION --region $AWS_REGION --force
```

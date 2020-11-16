---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 16
draft: false
---

### Cleaning up

To delete the resources used in this chapter:

```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml

helm uninstall aws-load-balancer-controller \
    -n kube-system

eksctl delete iamserviceaccount \
    --cluster eksworkshop-eksctl \
    --name aws-load-balancer-controller \
    --namespace kube-system \
    --wait

aws iam delete-policy \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy

kubectl delete -k github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master

eksctl delete fargateprofile \
  --name game-2048 \
  --cluster eksworkshop-eksctl
```

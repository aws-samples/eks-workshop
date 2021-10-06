---
title: "Cleanup Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

```bash
kubectl delete -f ~/environment/cluster-autoscaler/nginx.yaml

kubectl delete -f https://www.eksworkshop.com/beginner/080_scaling/deploy_ca.files/cluster-autoscaler-autodiscover.yaml

eksctl delete iamserviceaccount \
  --name cluster-autoscaler \
  --namespace kube-system \
  --cluster eksworkshop-eksctl \
  --wait

aws iam delete-policy \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy

export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='eksworkshop-eksctl']].AutoScalingGroupName" --output text)

aws autoscaling \
  update-auto-scaling-group \
  --auto-scaling-group-name ${ASG_NAME} \
  --min-size 3 \
  --desired-capacity 3 \
  --max-size 3

kubectl delete hpa,svc php-apache

kubectl delete deployment php-apache

kubectl delete pod load-generator

cd ~/environment

rm -rf ~/environment/cluster-autoscaler

kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml

kubectl delete ns metrics

helm uninstall kube-ops-view

unset ASG_NAME
unset AUTOSCALER_VERSION
unset K8S_VERSION
```

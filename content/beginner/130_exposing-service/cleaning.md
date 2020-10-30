---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---

### Cleaning up

To delete the resources used in this chapter:

```bash
kubectl delete -f ~/environment/run-my-nginx.yaml
kubectl delete ns my-nginx
rm ~/environment/run-my-nginx.yaml

curl -s https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml \
    | sed 's=alb.ingress.kubernetes.io/target-type: ip=alb.ingress.kubernetes.io/target-type: instance=g' \
    | kubectl delete -f -

helm uninstall aws-load-balancer-controller \
    -n kube-system

kubectl delete -k github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master

eksctl delete iamserviceaccount \
    --cluster eksworkshop-eksctl \
    --name aws-load-balancer-controller \
    --namespace kube-system \
    --wait

aws iam delete-policy \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy
```

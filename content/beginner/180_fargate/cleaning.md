---
title: "Clean Up"
date: 2019-04-09T00:00:00-03:00
weight: 16
draft: false
---

### Cleaning up

To delete the resources used in this chapter:

```bash

# Delete ingress
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-ingress.yaml

# Delete service
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-service.yaml

# Delete deployment
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-deployment.yaml

# Delete alb-ingress-gateway
helm -n 2048-game delete 2048-game

# Delete service account
eksctl delete iamserviceaccount \
  --name alb-ingress-controller \
  --namespace 2048-game \
  --cluster eksworkshop-eksctl

# Delete Kubernetes RBAC
kubectl delete -f ~/environment/fargate/rbac-role.yaml

# Delete Fargate profile
eksctl delete fargateprofile \
  --name 2048-game \
  --cluster eksworkshop-eksctl

# Delete namespace
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-namespace.yaml

# Delete IAM policy
aws iam delete-policy --policy-arn $FARGATE_POLICY_ARN

cd ~/environment
rm -rf ~/environment/fargate
```

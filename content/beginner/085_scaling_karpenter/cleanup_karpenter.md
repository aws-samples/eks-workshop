---
title: "Cleanup Karpenter"
weight: 65
---

## Cleanup

Start by deleting the deployment and wait for nodes to be removed by karpenter.
```bash
kubectl delete deployment inflate
```
When there is no more nodes managed by karpenter you can remove it and associated infrastructure.
```bash
kubectl get nodes -l karpenter.sh/provisioner-name
```

You can cleanup the rest via those commands:
```bash
helm uninstall karpenter --namespace karpenter
eksctl delete iamserviceaccount --cluster ${CLUSTER_NAME} --name karpenter --namespace karpenter
aws cloudformation delete-stack --stack-name Karpenter-${CLUSTER_NAME}
```
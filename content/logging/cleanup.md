---
title: "Cleanup Logging"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

```
kubectl delete -f ~/environment/fluentd/fluentd_example.yaml
rm -rf ~/environment/fluentd/
aws es delete-elasticsearch-domain --domain-name kubernetes-logs
aws logs delete-log-group --log-group-name /eks/eksworkshop-eksctl/containers
aws iam delete-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker
```
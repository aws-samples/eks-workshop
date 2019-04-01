---
title: "Cleanup Logging"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

```
cd ~/environment
kubectl delete -f ~/environment/fluentd/fluentd.yml
rm -rf ~/environment/fluentd/
aws es delete-elasticsearch-domain --domain-name kubernetes-logs
aws logs delete-log-group --log-group-name /eks/eksworkshop-eksctl/containers
rm -rf ~/environment/iam_policy/
```

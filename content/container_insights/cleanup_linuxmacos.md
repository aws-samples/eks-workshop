---
title: "LinuxmacOS"
chapter: false
disableToc: true
hidden: true
---

##### Linux / macOS users

```
export Cluster_Name=eksworkshop-eksctl
export AWS_REGION=us-east-1

curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/Cluster_Name/;s/{{region_name}}/AWS_REGION/" | kubectl delete -f -
```
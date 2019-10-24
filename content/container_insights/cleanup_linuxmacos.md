---
title: "LinuxmacOS"
chapter: false
disableToc: true
hidden: true
---

##### Linux / macOS users

Make sure you replace **<CLUSTER_NAME>** and **<REGION_NAME>** with your EKS cluster name and AWS region the cluster is in.

```
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/Cluster_Name/;s/{{region_name}}/Region/" | kubectl delete -f -
```
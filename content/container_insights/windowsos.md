---
title: "Windows"
chapter: false
disableToc: true
hidden: true
---

##### Windows users

Make sure you replace **<CLUSTER_NAME>** and **<REGION_NAME>** with your EKS cluster name and AWS region the cluster is in.


```
kubectl apply -f (New-Item -ItemType "File" -Name "containerinsights.yml" -Value ((Invoke-WebRequest -Uri https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml).Content -replace "{{cluster_name}}","<CLUSTER_NAME>" -replace "{{region_name}}","<REGION_NAME>"))
```

---
title: "Windows"
chapter: false
disableToc: true
hidden: true
---

##### Windows users

```
Set-Item -Path Env:Cluster_Name -Value "eksworkshop-eksctl"
Set-Item -Path Env:AWS_REGION -Value "us-east-1"

kubectl apply -f (New-Item -ItemType "File" -Name "containerinsights.yml" -Force -Value ((Invoke-WebRequest -Uri https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml).Content -replace "{{cluster_name}}", $env:Cluster_Name -replace "{{region_name}}", $env:AWS_REGION))
```
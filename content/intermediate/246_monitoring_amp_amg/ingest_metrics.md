---
title: "Ingest Metrics into AMP"
date: 2021-01-21T22:27:17-05:00
draft: false
weight: 30
---

Amazon Managed Service for Prometheus does not directly scrape operational metrics from containerized workloads in a Kubernetes cluster. It requires users to deploy and manage a standard Prometheus server, or an OpenTelemetry agent such as the AWS Distro for OpenTelemetry Collector in their cluster to perform this task.

#### Execute the following commands to deploy the Prometheus server on the EKS cluster

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create ns prometheus
```

#### Create a file called amp_ingest_override_values.yaml with the following content in it.

```
serviceAccounts:
  ## Disable alert manager roles
  ##
  server:
        name: "iamproxy-service-account"
  alertmanager:
    create: false

  ## Disable pushgateway
  ##
  pushgateway:
    create: false

server:
  remoteWrite:
    -
      queue_config:
        max_samples_per_send: 1000
        max_shards: 200
        capacity: 2500

  ## Use a statefulset instead of a deployment for resiliency
  ##
  statefulSet:
    enabled: true

  ## Store blocks locally for short time period only
  ##
  retention: 1h
  
## Disable alert manager
##
alertmanager:
  enabled: false

## Disable pushgateway
##
pushgateway:
  enabled: false
```
#### Execute the following command to install the Prometheus server configuration and configure the remoteWrite endpoint

```
export SERVICE_ACCOUNT_IAM_ROLE=EKS-AMP-ServiceAccount-Role
export SERVICE_ACCOUNT_IAM_ROLE_ARN=$(aws iam get-role --role-name $SERVICE_ACCOUNT_IAM_ROLE --query 'Role.Arn' --output text)
WORKSPACE_ID=$(aws amp list-workspaces --alias eks-workshop | jq .workspaces[0].workspaceId -r)
helm install prometheus-for-amp prometheus-community/prometheus -n prometheus -f ./amp_ingest_override_values.yaml \
--set serviceAccounts.server.annotations."eks\.amazonaws\.com/role-arn"="${SERVICE_ACCOUNT_IAM_ROLE_ARN}" \
--set server.remoteWrite[0].url="https://aps-workspaces.${AWS_REGION}.amazonaws.com/workspaces/${WORKSPACE_ID}/api/v1/remote_write" \
--set server.remoteWrite[0].sigv4.region=${AWS_REGION}
```

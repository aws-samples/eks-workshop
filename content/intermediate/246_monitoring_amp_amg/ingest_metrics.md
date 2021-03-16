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
helm install prometheus-for-amp prometheus-community/prometheus -n prometheus
```
The AWS signing proxy can now be deployed to the Amazon EKS cluster with the following YAML manifest. Now substitute the placeholder variable `${AWS_REGION}` with the appropriate AWS Region name, replace `${IAM_PROXY_PROMETHEUS_ROLE_ARN}` with the ARN of the EKS-AMP-ServiceAccount-Role you created and replace the placeholder `${WORKSPACE_ID}` with the AMP workspace ID you created earlier. The signing proxy references a Docker image from a public repository in ECR.

#### Create a file called amp_ingest_override_values.yaml with the following content in it.

```
serviceAccounts:
    server:
        name: "iamproxy-service-account"
        annotations:
            eks.amazonaws.com/role-arn: "${IAM_PROXY_PROMETHEUS_ROLE_ARN}"
server:
  sidecarContainers:
    aws-sigv4-proxy-sidecar:
        image: public.ecr.aws/aws-observability/aws-sigv4-proxy:1.0
        args:
        - --name
        - aps
        - --region
        - ${AWS_REGION}
        - --host
        - aps-workspaces.${AWS_REGION}.amazonaws.com
        - --port
        - :8005
        ports:
        - name: aws-sigv4-proxy
          containerPort: 8005
  statefulSet:
      enabled: "true"
  remoteWrite:
      - url: http://localhost:8005/workspaces/${WORKSPACE_ID}/api/v1/remote_write
```
#### Execute the following command to modify the Prometheus server configuration to deploy the signing proxy and configure the remoteWrite endpoint

```
helm upgrade --install prometheus-for-amp prometheus-community/prometheus -n prometheus -f ./amp_ingest_override_values.yaml
```

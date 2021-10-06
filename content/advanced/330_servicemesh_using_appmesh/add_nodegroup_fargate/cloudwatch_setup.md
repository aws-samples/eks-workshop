---
title: "Observability Setup"
date: 2020-01-27T08:30:11-07:00
weight: 23
draft: false
---

#### Enable Amazon Cloudwatch Container Insights 

Create an IAM role for the cloudwatch-agent service account
```bash
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace amazon-cloudwatch \
  --name cloudwatch-agent \
  --attach-policy-arn  arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --override-existing-serviceaccounts \
  --approve
```
{{< output >}}
2021-05-02 17:52:36 [ℹ]  eksctl version 0.45.0
2021-05-02 17:52:36 [ℹ]  using region $AWS_REGION
2021-05-02 17:52:36 [ℹ]  1 existing iamserviceaccount(s) (prodcatalog-ns/prodcatalog-envoy-proxies) will be excluded
2021-05-02 17:52:36 [ℹ]  1 iamserviceaccount (amazon-cloudwatch/cloudwatch-agent) was included (based on the include/exclude rules)
2021-05-02 17:52:36 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2021-05-02 17:52:36 [ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "amazon-cloudwatch/cloudwatch-agent", create serviceaccount "amazon-cloudwatch/cloudwatch-agent" } }
2021-05-02 17:52:36 [ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-cloudwatch-agent"
2021-05-02 17:52:37 [ℹ]  deploying stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-cloudwatch-agent"
2021-05-02 17:52:37 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-cloudwatch-agent"
2021-05-02 17:53:10 [ℹ]  created namespace "amazon-cloudwatch"
2021-05-02 17:53:10 [ℹ]  created serviceaccount "amazon-cloudwatch/cloudwatch-agent"
{{< /output >}}

Create an IAM role for the fluent service account
```bash
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace amazon-cloudwatch \
  --name fluentd \
  --attach-policy-arn  arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --override-existing-serviceaccounts \
  --approve
```
{{< output >}}
2021-05-02 17:54:09 [ℹ]  eksctl version 0.45.0
2021-05-02 17:54:09 [ℹ]  using region $AWS_REGION
2021-05-02 17:54:10 [ℹ]  2 existing iamserviceaccount(s) (amazon-cloudwatch/cloudwatch-agent,prodcatalog-ns/prodcatalog-envoy-proxies) will be excluded
2021-05-02 17:54:10 [ℹ]  1 iamserviceaccount (amazon-cloudwatch/fluentd) was included (based on the include/exclude rules)
2021-05-02 17:54:10 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2021-05-02 17:54:10 [ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "amazon-cloudwatch/fluentd", create serviceaccount "amazon-cloudwatch/fluentd" } }
2021-05-02 17:54:10 [ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-fluentd"
2021-05-02 17:54:10 [ℹ]  deploying stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-fluentd"
2021-05-02 17:54:10 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-fluentd"
2021-05-02 17:54:44 [ℹ]  created serviceaccount "amazon-cloudwatch/fluentd"
{{< /output >}}

Now, Deploy Container Insights for Managed Nodegroup
```bash
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/eksworkshop-eksctl/;s/{{region_name}}/${AWS_REGION}/" | kubectl apply -f -    
```
{{< output >}}
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                Dload  Upload   Total   Spent    Left  Speed
100 15552  100 15552    0     0  45840      0 --:--:-- --:--:-- --:--:-- 45876
namespace/amazon-cloudwatch configured
serviceaccount/cloudwatch-agent configured
clusterrole.rbac.authorization.k8s.io/cloudwatch-agent-role created
clusterrolebinding.rbac.authorization.k8s.io/cloudwatch-agent-role-binding created
configmap/cwagentconfig created
daemonset.apps/cloudwatch-agent created
configmap/cluster-info created
serviceaccount/fluentd configured
clusterrole.rbac.authorization.k8s.io/fluentd-role created
clusterrolebinding.rbac.authorization.k8s.io/fluentd-role-binding created
configmap/fluentd-config created
{{< /output >}}

The command above will:

* Create the `Namespace` amazon-cloudwatch.
* Create all the necessary security objects for both DaemonSet:
  * `SecurityAccount`.
  * `ClusterRole`.
  * `ClusterRoleBinding`.
* Deploy Cloudwatch-Agent (responsible for sending the **metrics** to CloudWatch) as a `DaemonSet`.
* Deploy fluentd (responsible for sending the **logs** to Cloudwatch) as a `DaemonSet`.
* Deploy `ConfigMap` configurations for both DaemonSets.

{{% notice info %}}
You can find the full information and manual install steps [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html).
{{% /notice %}}

You can verify all the `DaemonSets` have been deployed by running the following command.

```bash
kubectl -n amazon-cloudwatch get daemonsets
```

{{< output >}}
NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
cloudwatch-agent     3         3         3       3            3           <none>          2m43s
fluentd-cloudwatch   3         3         3       3            3           <none>          2m43s
{{< /output >}}

You can also verify the deployment of `DaemonSets` by logging into console and navigate to Amazon EKS -> Cluster -> Workloads,
![DaemonSets](/images/app_mesh_fargate/cloudwatchd.png)

#### Enable Prometheus Metrics in CloudWatch

Create an IAM role for the prometheus service account
```bash
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace amazon-cloudwatch \
  --name cwagent-prometheus \
  --attach-policy-arn  arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --override-existing-serviceaccounts \
  --approve
```
{{< output >}}
2021-05-02 18:00:25 [ℹ]  eksctl version 0.45.0
2021-05-02 18:00:25 [ℹ]  using region $AWS_REGION
2021-05-02 18:00:26 [ℹ]  3 existing iamserviceaccount(s) (amazon-cloudwatch/cloudwatch-agent,amazon-cloudwatch/fluentd,prodcatalog-ns/prodcatalog-envoy-proxies) will be excluded
2021-05-02 18:00:26 [ℹ]  1 iamserviceaccount (amazon-cloudwatch/cwagent-prometheus) was included (based on the include/exclude rules)
2021-05-02 18:00:26 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2021-05-02 18:00:26 [ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "amazon-cloudwatch/cwagent-prometheus", create serviceaccount "amazon-cloudwatch/cwagent-prometheus" } }
2021-05-02 18:00:26 [ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-cwagent-prometheus"
2021-05-02 18:00:26 [ℹ]  deploying stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-cwagent-prometheus"
2021-05-02 18:00:26 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-amazon-cloudwatch-cwagent-prometheus"
2021-05-02 18:00:59 [ℹ]  created serviceaccount "amazon-cloudwatch/cwagent-prometheus"
{{< /output >}}

Install Prometheus Agent
```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/service/cwagent-prometheus/prometheus-eks.yaml
```
{{< output >}}
namespace/amazon-cloudwatch unchanged
configmap/prometheus-cwagentconfig created
configmap/prometheus-config created
serviceaccount/cwagent-prometheus configured
clusterrole.rbac.authorization.k8s.io/cwagent-prometheus-role created
clusterrolebinding.rbac.authorization.k8s.io/cwagent-prometheus-role-binding created
deployment.apps/cwagent-prometheus created
{{< /output >}}

Confirm that the agent is running 
```bash
kubectl get pod -l "app=cwagent-prometheus" -n amazon-cloudwatch
```
{{< output >}}
NAME                                 READY   STATUS    RESTARTS   AGE
cwagent-prometheus-95896694d-99pwb   1/1     Running   0          2m33s
{{< /output >}}


#### Enable Logging for Fargate

Amazon EKS with Fargate supports a built-in log router, which means there are no sidecar containers to install or maintain. Apply a ConfigMap to your Amazon EKS cluster with a Fluent Conf data value that defines where container logs are shipped to.
This logging ConfigMap has to be used in a fixed namespace called aws-observability has a cluster-wide effect, meaning that you can send application-level logs from any application in any namespace.

In this workshop, we will show you how to use cloudwatch_logs to send logs from a workload running in an EKS on Fargate cluster to CloudWatch.

First, create the dedicated aws-observability namespace and the ConfigMap for Fluent Bit
```bash
cd eks-app-mesh-polyglot-demo
envsubst < ./deployment/fluentbit-config.yaml | kubectl apply -f -
```
{{< output >}}
namespace/aws-observability created
configmap/aws-logging created
{{< /output >}}

Next, verify if the Fluent Bit ConfigMap is deployed correctly
```bash
kubectl -n aws-observability get cm
```
{{< output >}}
NAME          DATA   AGE
aws-logging   1      18s
{{< /output >}}

With Fluent Bit set up we next need to give it the permission to write to CloudWatch. We do that by first downloading the policy locally:
```bash
curl -o permissions.json \
     https://raw.githubusercontent.com/aws-samples/amazon-eks-fluent-logging-examples/mainline/examples/fargate/cloudwatchlogs/permissions.json
```
{{< output >}}
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                Dload  Upload   Total   Spent    Left  Speed
100   215  100   215    0     0   1023      0 --:--:-- --:--:-- --:--:--  1023
{{< /output >}}
And next we create the policy:
```bash
aws iam create-policy \
        --policy-name FluentBitEKSFargate \
        --policy-document file://permissions.json 
```
{{< output >}}
{
    "Policy": {
        "PolicyName": "FluentBitEKSFargate", 
        "PermissionsBoundaryUsageCount": 0, 
        "CreateDate": "2021-02-04T07:11:07Z", 
        "AttachmentCount": 0, 
        "IsAttachable": true, 
        "PolicyId": "ANPAV45SCB72QX3SZN2RS", 
        "DefaultVersionId": "v1", 
        "Path": "/", 
        "Arn": "arn:aws:iam::405710966773:policy/FluentBitEKSFargate", 
        "UpdateDate": "2021-02-04T07:11:07Z"
    }
}
{{< /output >}}

And then, Attach the Policy to the Pod Execution Role of our EKS on Fargate cluster                                            
```bash
export PodRole=$(aws eks describe-fargate-profile --cluster-name eksworkshop-eksctl --fargate-profile-name fargate-productcatalog --query 'fargateProfile.podExecutionRoleArn' | sed -n 's/^.*role\/\(.*\)".*$/\1/ p')
aws iam attach-role-policy \
        --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/FluentBitEKSFargate \
        --role-name ${PodRole}
echo $PodRole
```
Log into console and navigate to EKS -> Cluster -> Configuration-> Compute, select `fargate-productcatalog` Fargate Profile, you will see the below page.
![nodegroup](/images/app_mesh_fargate/fargatepodrole.png)

Click on the Pod Execution Role. You should see the below `FluentBitEKSFargate` policy that was attached to the Pod Execution Role.
![nodegroup](/images/app_mesh_fargate/fluentbit.png)

#### (Optional) Enable Amazon EKS Control Plane logs 

{{% notice info %}}
If you enable Amazon EKS Control Plane logging, you will be charged the standard CloudWatch Logs data ingestion and storage costs for any logs sent to CloudWatch Logs from your cluster. You are also charged for any AWS resources, such as Amazon EC2 instances or Amazon EBS volumes, that you provision as part of your cluster.
{{% /notice %}}

CloudWatch logging for EKS control plane is not enabled by default due to data ingestion and storage costs. You can enable using below command.
```bash
eksctl utils update-cluster-logging \
    --enable-types all \
    --region ${AWS_REGION} \
    --cluster eksworkshop-eksctl \
    --approve
```

{{< output >}}
[ℹ]  eksctl version 0.37.0
[ℹ]  using region us-west-2
[✔]  CloudWatch logging for cluster "eksworkshop-eksctl" in "us-west-2" is already up-to-date
{{< /output >}}

You can log into console and navigate to Amazon EKS -> Cluster -> Logging
![\[Image NOT FOUND\]](/images/app_mesh_fargate/consolecontrol.png)

Congratulations!! You have completed the basic setup for EKS and Observability, Now lets move to the fun part of deploying our Product Catalog Application.


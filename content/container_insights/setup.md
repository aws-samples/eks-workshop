---
title: "Setup Container Insights"
chapter: false
weight: 1
---

There are 2 components that work together to collect Metrics, Logs data for Container Insights in EKS

1. CloudWatch agent
2. FluentD

#### Application setup
In this section we will be setting up Container Insights for the ECS Demo app that you created in the **Deploy the Example Microservices** section earlier. If you haven't done that yet, go ahead and deploy the application and come back here again to proceed with Container Insights.

------------------------------------------------------------

#### Setup IAM role
In order for the EKS worker nodes to be able to send logs and metrics to CloudWatch, follow the steps below

* Open the [Amazon EC2 console](https://console.aws.amazon.com/ec2/)

* Select one of the worker node instances and choose the IAM role in the description.

* On the IAM role page, choose **Attach policies**.

* In the list of policies, select the check box next to **CloudWatchAgentServerPolicy**. If necessary, use the search box to find this policy.

* Choose **Attach policies**

------------------------------------------------------------

#### Setup Container Insights

##### Linux/macOS users

If you are using Linux or macOS, run the following command to setup Container Insights on your EKS cluster. Make sure you replace **<CLUSTER_NAME>** and **<REGION_NAME>** with your EKS cluster name and AWS region the cluster is in.

`curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/Cluster_Name/;s/{{region_name}}/Region/" | kubectl apply -f -`

##### Windows users

If you're using Windows, use the below command to setup Container Insights on your EKS cluster.Make sure you replace **<CLUSTER_NAME>** and **<REGION_NAME>** with your EKS cluster name and AWS region the cluster is in.

`kubectl apply -f (New-Item -ItemType "File" -Name "containerinsights.yml" -Value ((Invoke-WebRequest -Uri https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml).Content -replace "{{cluster_name}}","<CLUSTER_NAME>" -replace "{{region_name}}","<REGION_NAME>"))`

{{% children showhidden="false" %}}

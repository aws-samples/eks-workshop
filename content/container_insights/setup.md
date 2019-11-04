---
title: "Setup Container Insights"
chapter: false
weight: 1
---

There are 2 components that work together to collect Metrics, Logs data for Container Insights in EKS

1. CloudWatch agent
2. FluentD 

#### Application setup
In this section we will be setting up Container Insights for the [Example Microservices](../../deploy) module. If you haven't done that yet, go ahead and deploy the application and come back here again to proceed with Container Insights.

------------------------------------------------------------

#### Setup IAM policy

In order for the EKS worker nodes to be able to send logs and metrics to CloudWatch, follow the steps below

```
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set
```
If ROLE_NAME is not set, please review: [this](../../eksctl/test/)

You could also go to the EC2 console and get the IAM Role the EKS nodes are assuming from there. If you do so, make sure you replace **$ROLE_NAME** in the below command to the name of the role you got from the EC2 console. 

{{% notice info %}}
Caution -  This is NOT the Role ARN, but the friendly role name which needs to be used here.
{{% /notice %}}

```
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy --role-name $ROLE_NAME
```

------------------------------------------------------------

#### Setup Container Insights

{{% notice info %}}
Ensure you change the value of **AWS_REGION** environment variable to the one that fits your needs
{{% /notice  %}}

{{< tabs name="Setup Instructions" >}}
{{{< tab name="Linux / macOS" include="linuxmacos.md" />}}
{{{< tab name="Windows" include="windowsos.md" />}}
{{< /tabs >}}

{{% children showhidden="false" %}}
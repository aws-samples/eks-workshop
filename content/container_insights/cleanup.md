---
title: "Cleanup Resources"
chapter: false
weight: 6
---

#### Delete CloudWatch Alarm
* Navigate to [CloudWatch Alarms](https://console.aws.amazon.com/cloudwatch/home#alarmsV2:) page and select the **Pod Restart Count** alarm.
* Click **Actions** and **Delete** option from the dropdown. Click **Delete** in the confirmation window to delete the alarm

#### Delete Container Insights

{{% notice info %}}
Ensure you change the value of **AWS_REGION** environment variable to the one that fits your needs
{{% /notice  %}}

{{< tabs name="Setup Instructions" >}}
{{{< tab name="Linux / macOS" include="cleanup_linuxmacos.md" />}}
{{{< tab name="Windows" include="cleanup_windowsos.md" />}}
{{< /tabs >}}

{{% children showhidden="false" %}}

#### Cleanup example microservices

Follow [these steps](../../deploy/cleanup) to clean up example microservices from your EKS cluster
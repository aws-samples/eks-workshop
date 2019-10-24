---
title: "CloudWatch Logs Insights"
chapter: false
weight: 5
---
#### Querying Logs from EKS

Navigate to [CloudWatch Logs Insights](https://console.aws.amazon.com/cloudwatch/home#logs-insights:) and select **aws/containerinsights/eksworkshop-eksctl/performance** Log Group as shown below

![Container Insights](/images/ContainerInsights12.png)

Copy and paste the following query into the textbox and click **Run query**

```
fields kubernetes.pod_name, kubernetes.host
| stats count_distinct(kubernetes.pod_name) as Number_of_Pods by kubernetes.host  
```

This query will return the a table that contains the number of Pods that are running on each EKS worker node.

-----------------------------

You can also apply filters to the query as shown below

```
fields kubernetes.pod_name, kubernetes.host
| filter kubernetes.pod_name like 'ecsdemo'
| stats count_distinct(kubernetes.pod_name) as Number_of_Pods by kubernetes.host  
```

The above query will query will filter the pods with name containing the string **ecsdemo**. Your output should look similar to the one shown below.

![Container Insights](/images/ContainerInsights13.png)

---------------------

The following query shows the amount of data (in KB) received and sent by the **ecsdemo-frontend** pod every 5 minutes

```
fields kubernetes.pod_name, pod_interface_network_rx_bytes, pod_interface_network_tx_bytes
| filter kubernetes.pod_name like 'ecsdemo-frontend'
| filter (pod_interface_network_rx_bytes)  > 0
| stats sum(pod_interface_network_rx_bytes/1024) as KB_received, sum(pod_interface_network_tx_bytes/1024) as KB_sent  by bin(5m)
| sort by Timestamp
| limit 100
```
Your result should look similar to the one shown below

![Container Insights](/images/ContainerInsights14.png)

You could also switch to the **Visualization** tab to see the data plotted on a timeseries graph as shown below

![Container Insights](/images/ContainerInsights15.png)

You can add the visualization to a CloudWatch Dashboard by clicking on **Actions** and selecting **Add to Dashboard** and following the steps in the wizard.

Learn more about CloudWatch Log querying syntax from the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)

---
title: "CloudWatch Logs Insights"
chapter: false
weight: 5
---
#### What is Logs Insights?

[CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html) is a fully integrated, interactive, and pay-as-you-go log analytics service for CloudWatch. CloudWatch Logs Insights enables you to explore, analyze, and visualize your logs instantly, allowing you to troubleshoot operational problems with ease.

#### Querying Logs from EKS

Navigate to [CloudWatch Logs Insights](https://console.aws.amazon.com/cloudwatch/home#logs-insights:) and select **aws/containerinsights/eksworkshop-eksctl/performance** Log Group as shown below

![Container Insights](/images/ContainerInsights12.png)

Copy and paste the following query into the textbox and click **Run query**

```
fields kubernetes.pod_name, kubernetes.host
| stats count_distinct(kubernetes.pod_name) as Number_of_Pods by kubernetes.host  
```

This query will return the table that contains the number of Pods that are running on each EKS worker node.

-----------------------------

You can also apply filters to the query as shown below

```
fields kubernetes.pod_name, kubernetes.host
| filter kubernetes.pod_name like 'ecsdemo'
| stats count_distinct(kubernetes.pod_name) as Number_of_Pods by kubernetes.host  
```

The above query will filter the pods with name containing the string **ecsdemo**. Your output should look similar to the one shown below.

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

### Creating custom Dashboards

You can easily create a custom dashboard with various types of widgets. Follow the instructions below to create a custom dashboard.

{{% notice info %}}
The AWS region is set to us-east-1, if your Container Insights metrics are in a region other than "us-east-1", replace "us-east-1" with the appropriate region
{{% /notice  %}}

* Login to the Amazon CloudWatch Console: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:
* Click on the **Create dashboard** button
* Enter a new **Dashboard name** (e.g., k8s-HealthDashboard_MyClusterName)
* Click the Create button
* Click the Cancel link
* Click on the **Actions** button
* Select the **View/edit source** menu item
* Copy the content of the JSON below and paste to replace the entire content of the text area
* Click the **Update** button

{{% notice info %}}
If you did not name your cluster as **eksworkshop-eksctl**, make sure you replace all the instances of **"eksworkshop-eksctl"** to the name of your cluster in the json below
{{% /notice  %}}

```
{
    "widgets": [
        {
            "type": "log",
            "x": 9,
            "y": 6,
            "width": 15,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/containerinsights/eksworkshop-eksctl/performance' | filter Type=\"Pod\"\n| stats min(pod_number_of_containers) as Requested, min(pod_number_of_running_containers) as Running, ceil(avg(pod_number_of_containers-pod_number_of_running_containers)) as PodsMissing by Namespace, PodName, kubernetes.pod_name as PodID\n| sort PodsMissing desc\n| limit 50",
                "region": "us-east-1",
                "stacked": false,
                "title": "Pods Requested vs Running",
                "view": "table"
            }
        },
        {
            "type": "log",
            "x": 6,
            "y": 12,
            "width": 18,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/containerinsights/eksworkshop-eksctl/performance' | filter Type=\"Container\" and ispresent(container_status) and container_status != \"Running\"\n| fields @timestamp as Timestamp, Namespace, PodName, kubernetes.pod_name as PodID, container_status as ContainerStatus, container_status_reason as Reason, container_last_termination_reason as LastTerminationReason\n| sort @timestamp desc\n| limit 50\n",
                "region": "us-east-1",
                "stacked": false,
                "title": "Failures: Last Container Status (last 50)",
                "view": "table"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 6,
            "width": 9,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/containerinsights/eksworkshop-eksctl/performance' | stats max(pod_number_of_container_restarts) as Restarts by PodName, kubernetes.pod_name as PodID\n| filter Type=\"Pod\"\n| sort Restarts desc\n| limit 10\n",
                "region": "us-east-1",
                "stacked": false,
                "title": "Pod RESTARTS: Top 10",
                "view": "table"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "\n# Kubernetes (k8s) Cluster Health Dashboard\n"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 12,
            "width": 6,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/containerinsights/eksworkshop-eksctl/application' | stats count() as CountOfErrors by kubernetes.namespace_name as Namespace, kubernetes.container_name as ContainerName\n| filter stream=\"stderr\"\n| sort CountOfErrors desc\n",
                "region": "us-east-1",
                "stacked": false,
                "title": "Application Log Errors: Count by container name",
                "view": "table"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 18,
            "width": 24,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/containerinsights/eksworkshop-eksctl/performance' | filter Type=\"ContainerFS\"\n| stats floor(avg(container_filesystem_usage)/1024/1024) as StorageUsed_MB, floor(avg(container_filesystem_capacity)/1024/1024) as StorageAvailable_MB, floor(avg(container_filesystem_utilization)*100) as PercentUtilized by Namespace, kubernetes.container_name as ContainerName, InstanceId, device as DeviceMount, EBSVolumeId\n| sort PercentUtilized desc",
                "region": "us-east-1",
                "stacked": false,
                "title": "Disk Usage by Container Name",
                "view": "table"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 1,
            "width": 24,
            "height": 2,
            "properties": {
                "markdown": "\n## EKS Workshop \nhttps://eksworkshop.com/container_insights/logsinsights/\n"
            }
        },
        
        {
            "type": "metric",
            "x": 3,
            "y": 3,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "node_number_of_running_pods", "ClusterName", "eksworkshop-eksctl" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "stat": "Average",
                "period": 900,
                "title": "Count of Running Pods",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 9,
            "y": 3,
            "width": 6,
            "height": 3,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "ContainerInsights", "cluster_node_count", "ClusterName", "eksworkshop-eksctl" ]
                ],
                "region": "us-east-1",
                "title": "Count of Nodes"
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 3,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "cluster_failed_node_count", "ClusterName", "eksworkshop-eksctl", { "label": "_" } ]
                ],
                "view": "timeSeries",
                "region": "us-east-1",
                "title": "Count of Node Failure Conditions",
                "stat": "Average",
                "period": 300,
                "setPeriodToTimeRange": false,
                "stacked": false,
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                }
            }
        }
    ]
}
```

Learn more about CloudWatch Log querying syntax from the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)

---
title: "Explore Container Insights"
chapter: false
weight: 2
---
#### Validate Installation

Once the installation is complete, execute the following commands to ensure everything is setup correctly.

Execute the following command

```
kubectl get namespaces
```

You should be able to see a new namespace called **amazon-cloudwatch** listed amongst others

Now execute the following command

```
kubectl get daemonsets -n amazon-cloudwatch
```

You should be able to see two daemonsets called **cloudwatch-agent** and **fluentd-cloudwatch** listed.
Finally, let's check if the Pods are in Running status. Execute the following command to find that out.

```
kubectl get pods -n amazon-cloudwatch
```
    
You should see 3 instances of **cloudwatch-agent** and **fluentd-cloudwatch** pods running.

![Screenshot checking Container Insights installation](/images/ContainerInsights9.png) 

#### Verify that the logs are streaming into CloudWatch
Login to AWS console and navigate to [Amazon CloudWatch Logs](https://console.aws.amazon.com/cloudwatch/home#logs:)
Type **/aws/containerinsights/eksworkshop-eksctl** in the filter texbox and press enter. You should be able to see 4 Log Groups as shown below each one of them containing Application, Dataplane, Host and Performance Log Streams respectively.

![Container Insights](/images/ContainerInsights6.png)

Navigate to [Amazon CloudWatch home page](https://console.aws.amazon.com/cloudwatch). Select **Container Insights** from the drop down on the home page as shown below

![Container Insights](/images/ContainerInsights1.png)

Ensure **EKS Clusters** is selected in the first dropdown and select the **eksworkshop-eksctl** cluster in the second dropdown. You will be able to see several built-in charts showing various cluster level metrics such as CPU Utilization, Memory Usage, Disk Usage, Network and so on in the default dashboard as shown below

![Container Insights](/images/ContainerInsights2.png)

You can also view Performance Logs, Application Logs, Control Plane Logs ([when enabled](https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-control-plane-logging.html)), Data Plane Logs and Host Logs by simply selecting the cluster name and clicking on Actions dropdown as shown below

![Container Insights](/images/ContainerInsights3.png)

You can also drill down into the cluster and see the metrics at the Pod level by simply selecting **EKS Pods** in the first drop down as shown below

![Container Insights](/images/ContainerInsights5.png)

Likewise, you can also see insights at the Node level as well. You just have to select **EKS Nodes** in the first drop down and select a particular node in the second drop down to see metrics specific to that node.

![Container Insights](/images/ContainerInsights11.png)


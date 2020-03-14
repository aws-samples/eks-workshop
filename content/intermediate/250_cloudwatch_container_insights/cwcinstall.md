---
title: "Installing Container Insights"
chapter: false
weight: 5
---


#### Installing CloudWatch Container Insights using QuickStart: 

We'll be using the QuickStart to make the install simple and easy for the Container Insights. 

You can find the full information and manual install steps here: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html 


From your Cloud9 Terminal you will just need to run the following command. Make sure to replace the region name placeholder `<AWS_REGION_NAME>` with the region name where the cluster has been deployed.


```
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/eksworkshop-eksctl/;s/{{region_name}}/<AWS_REGION_NAME>/" | kubectl apply -f -
```

With this quick start it will push the necessary daemon sets to collect the data for CloudWatch Containers Insights.

![alt text](/images/ekscwci/cwdaemon.png "CW Daemon")


That's it. It's that simple to install the agent and get it up and running. You can follow the manual steps in the full documentation, but with the Quickstart the deployment of the Daemon is easy and quick! 

### Now onto verifying the data is being collected! 
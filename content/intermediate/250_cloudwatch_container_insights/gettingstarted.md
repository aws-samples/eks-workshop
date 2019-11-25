---
title: "Getting Started"
chapter: false
weight: 1
---

After you've completed the prerequisites and Helm is installed and working; We can deploy our Wordpress site.  This Helm chart will deploy MariaDB and Wordpress as well as configure a service ingress point for us to access the site through an elastic load balancer. 

For our testing we’ll be deploying Wordpress. We could just use a PHP file on the nodes and run NGINX to test as well, but with this Wordpress install you get experience deploying a Helm chart. And can use the load testing tool to hit various URLs on the Wordpress structure to generate additional network traffic load with multiple concurrent connections. 

#### We'll be using the following tools in this lab: 

- Helm: To install Wordpress on our cluster
- CloudWatch Container Insights: To collect data from our cluster
- Siege: To load test our Wordpress and EKS Cluster
- CloudWatch Container Insights Dashboard: To Visualize our container performance and load
- CloudWatch Metrics: To set an Alarm for when our EKS cluster is under heavy load 


### Lets get started! 










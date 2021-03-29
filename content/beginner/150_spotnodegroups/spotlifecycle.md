---
title: "Spot Configuration and Lifecycle"
date: 2021-03-08T10:00:00-08:00
weight: 20
draft: false
---

#### View the Spot Managed Node Group Configuration

Use the AWS Management Console to inspect the Spot managed node group deployed in your Kubernetes cluster. Select **Elastic Kubernetes Service**, click on **Clusters**, and then on **eksworkshop-eksctl** cluster. Select the **Configuration** tab and **Compute** sub tab. You can see 2 node groups created - one On-Demand node group and one Spot node groups.

Click on **ng-spot** group and you can see the instance types set from the create command.

Click on the Auto Scaling group name in the **Details** tab. Scroll to the Purchase options and instance types settings. Note how Spot best practices are applied out of the box: 
* **Capacity Optimized** allocation strategy, which will launch Spot Instances from the most-available spare capacity pools. This results in minimizing the Spot Interruptions. 
* **Capacity Rebalance** helps EKS managed node groups manage the lifecycle of the Spot Instance by proactively replacing instances that are at higher risk of being interrupted. This results in proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2

![Spot Node Groups Configuration](/images/spotworkers/asg_configuration.png)

#### Understand Spot Interruption

Spot instances are unused EC2 instances that might be reclaimed when OnDemand users require capacity from a specific capacity pool. A Spot capacity pool is a set of unused EC2 instances with the same instance type (for example, m5.large) and Availability Zone. It is possible that your Spot Instance might be interrupted. In this case the Spot Instances are sent an interruption notice two minutes ahead to gracefully wrap up things. EKS Spot Managed node groups re-provision capacity from other available spot pools and redeploy the application elsewhere in the cluster.

**TO BE CORRECTED**
Spot managed node groups automatically deploys the [AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler) as a Kubernetes Deployment operating in the Queue Processor mode. The aws-node-termination-handler (NTH) running in Queue Processor mode will monitor an SQS queue of events from Amazon EventBridge for ASG lifecycle events, EC2 status change events, and Spot Interruption Termination Notice events. When NTH detects an instance is going down, we use the Kubernetes API to cordon the node to ensure no new work is scheduled there, then drain it, removing any existing work.
**TO BE CORRECTED**

The workflow for the NTH can be summarized as:

* Detects that a Spot Instance is being reclaimed or is at an elevated risk of being reclaimed
* Launches a new instance accordingly and waits for the new instance to report as healthy.
* [**Taint**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) and cordon the node to avoid scheduling more workload to the node, and finally
* [**Drain**](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) the pod, issuing a SIGTERM signal to the containers on the Pod to effect a graceful termination

This process avoids waiting for new capacity to be available when there is a termination notice, and instead procures capacity in advance, limiting the time that pods might be left pending.

![Spot Node Groups Architecture](/images/spotworkers/spot_rebalance_recommendation.png)
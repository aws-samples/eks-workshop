---
title: "AWS Node Termination Handler"
date: 2021-03-08T10:00:00-08:00
weight: 20
draft: false
---
#### AWS Node Termination Handler

Demand for Spot Instances can vary significantly, and as a consequence the availability of Spot Instances will also vary depending on how many unused EC2 instances are available. It is always possible that your Spot Instance might be interrupted. In this case the Spot Instances are sent an interruption notice two minutes ahead to gracefully wrap up things. We will deploy a pod on each spot instance to detect and redeploy applications elsewhere in the cluster.

Spot Managed node groups automatically deploys the [AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler) on each Spot Instance. This will monitor the EC2 metadata service on the instance for an interruption notice.

The workflow for the node termination handler can be summarized as:

* Identify that a Spot Instance is being reclaimed.
* Use the 2-minute notification window to gracefully prepare the node for termination.
* [**Taint**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) the node and cordon it off to prevent new pods from being placed.
* [**Drain**](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) connections on the running pods.
* Replace the pods on remaining nodes to maintain the desired capacity.


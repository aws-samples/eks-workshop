---
title: "Deploy The Spot Interrupt Handler"
date: 2018-08-07T12:32:40-07:00
weight: 20
draft: false
---

In this section, we will prepare our cluster to handle Spot interruptions.

If the available On-Demand capacity of a particular instance type is deleted, the Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things. We will deploy a pod on each spot instance to detect and redeploy applications elsewhere in the cluster.

The first thing that we need to do is deploy the [AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler) on each Spot Instance. This will monitor the EC2 metadata service on the instance for an interruption notice.
The termination handler consists of a `ServiceAccount`, `ClusterRole`, `ClusterRoleBinding`, and a `DaemonSet`.

The workflow can be summarized as:

* Identify that a Spot Instance is being reclaimed.
* Use the 2-minute notification window to gracefully prepare the node for termination.
* [**Taint**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) the node and cordon it off to prevent new pods from being placed.
* [**Drain**](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) connections on the running pods.
* Replace the pods on remaining nodes to maintain the desired capacity.

By default, the **aws-node-termination-handler** will run on all of your nodes (on-demand and spot). If your spot instances are labeled, you can configure `aws-node-termination-handler` to only run on your labeled spot nodes. If you're using the tag `lifecycle=Ec2Spot`, you can run the following to apply our spot-node-selector overlay.

```bash
kubectl apply -k https://github.com/aws/aws-node-termination-handler/config/overlays/spot-node-selector?ref=master
```

View the pods. There should be one for each spot node.

```bash
kubectl --namespace=kube-system get daemonsets 
```

---
title: "Deploy The Node Termination Handler"
date: 2018-08-07T12:32:40-07:00
weight: 40
draft: false
---

When users requests On-Demand instances from a pool to the point that the pool is depleted, the system will select a set of spot instances from the pool to be terminated. A Spot instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone, and network platform. The Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things. 

We will deploy a pod on each spot instance to detect the instance termination notification signal so that we can both terminate gracefully any pod that was running on that node, drain from load balancers and redeploy applications elsewhere in the cluster.

AWS Node Termination Handler does far more than just capture EC2 Spot Instance notification for terminations. There are other events such as [Scheduled Maintenance Events](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-instances-status-check_sched.html) that are taken into consideration. AWS Node Termination handler does also offer a Webhook that can be used to integrate with other applications to monitor and instrument this events. You can find more information about **[AWS Node Termination Handler following this link](https://github.com/aws/aws-node-termination-handler)**

The Helm chart we will use to deploy AWS Node Termination Handler on each Spot Instance uses a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). This will monitor the EC2 meta-data service on each of the EC2 Spot instances to capture EC2 interruption notices. 

Within the Node Termination Handler DaemonSet, the workflow can be summarized as:

* Identify that a Spot Instance is being reclaimed.
* Use the 2-minute notification window to gracefully prepare the node for termination.
* [**Taint**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) the node and cordon it off to prevent new pods from being placed.
* [**Drain**](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) connections on the running pods.
* Replace the pods on remaining nodes to maintain the desired capacity.

By default, **[aws-node-termination-handler](https://github.com/aws/aws-node-termination-handler)** will run on all of your nodes (on-demand and spot).
This also is our recommendation. Remember the termination handler does also handle maintenance events that can impact OnDemand instances!


```
helm repo add eks https://aws.github.io/eks-charts
helm install aws-node-termination-handler \
             --namespace kube-system \
             eks/aws-node-termination-handler
```

Verify that the pods are running on all nodes: 
```
kubectl get daemonsets --all-namespaces
```

Use **kube-ops-view** to confirm *AWS Node Termination Handler* DaemonSet has been deployed to all nodes.



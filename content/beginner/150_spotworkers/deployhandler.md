---
title: "Deploy the AWS Node Termination Handler"
date: 2018-08-07T12:32:40-07:00
weight: 20
draft: false
---
{{% notice info %}}

We need `Helm` to deploy the `AWS Node Termination Handler`, see [installing Helm](/beginner/060_helm/helm_intro/install/index.html) for instructions.

{{% /notice %}}
 
In this section, we will prepare our cluster to handle Spot interruptions.

Demand for Spot Instances can vary significantly, and as a consequence the availability of Spot Instances will also vary depending on how many unused EC2 instances are available. It is always possible that your Spot Instance might be interrupted. In this case the Spot Instances are sent an interruption notice two minutes ahead to gracefully wrap up things. We will deploy a pod on each spot instance to detect and redeploy applications elsewhere in the cluster.

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
helm repo add eks https://aws.github.io/eks-charts

helm upgrade --install aws-node-termination-handler \
             --namespace kube-system \
             --set nodeSelector.lifecycle=Ec2Spot \
              eks/aws-node-termination-handler
```

Verify that the pods are only running on node with label `lifecycle=Ec2Spot`
```bash
kubectl --namespace=kube-system get daemonsets 
```
![Spot Daemonset](/images/spotworkers/spot_get_ds.png)

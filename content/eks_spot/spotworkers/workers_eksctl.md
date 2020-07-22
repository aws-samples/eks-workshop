---
title: "Adding Spot Workers with eksctl"
date: 2018-08-07T11:05:19-07:00
weight: 30
draft: false
---

In this section we will deploy the instance types we selected and request nodegroups that adhere to Spot diversification best practices. For that we will use **[eksctl create nodegroup](https://eksctl.io/usage/managing-nodegroups/)** and eksctl configuration files to add the new nodes to the cluster.

Let's first create the configuration file:
```
cat <<EoF > ~/environment/spot_nodegroups.yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl
    region: $AWS_REGION
nodeGroups:
    - name: dev-4vcpu-16gb-spot
      minSize: 0
      maxSize: 5
      desiredCapacity: 1
      instancesDistribution:
        instanceTypes: ["m5.xlarge", "m5d.xlarge", "m4.xlarge","t3.xlarge","t3a.xlarge","m5a.xlarge","t2.xlarge"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotAllocationStrategy: capacity-optimized
      labels:
        lifecycle: Ec2Spot
        intent: apps
        aws.amazon.com/spot: "true"
      taints:
        spotInstance: "true:PreferNoSchedule"
      tags:
        k8s.io/cluster-autoscaler/node-template/label/lifecycle: Ec2Spot
        k8s.io/cluster-autoscaler/node-template/label/intent: apps
        k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot: "true"
        k8s.io/cluster-autoscaler/node-template/taint/spotInstance: "true:PreferNoSchedule"
      iam:
        withAddonPolicies:
          autoScaler: true
          cloudWatch: true
          albIngress: true
    - name: dev-8vcpu-32gb-spot
      minSize: 0
      maxSize: 5
      desiredCapacity: 1
      instancesDistribution:
        instanceTypes: ["m5.2xlarge", "m5d.2xlarge", "m4.2xlarge","t3.2xlarge","t3a.2xlarge","m5a.2xlarge","t2.2xlarge"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotAllocationStrategy: capacity-optimized
      labels:
        lifecycle: Ec2Spot
        intent: apps
        aws.amazon.com/spot: "true"
      taints:
        spotInstance: "true:PreferNoSchedule"
      tags:
        k8s.io/cluster-autoscaler/node-template/label/lifecycle: Ec2Spot
        k8s.io/cluster-autoscaler/node-template/label/intent: apps
        k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot: "true"
        k8s.io/cluster-autoscaler/node-template/taint/spotInstance: "true:PreferNoSchedule"
      iam:
        withAddonPolicies:
          autoScaler: true
          cloudWatch: true
          albIngress: true
EoF
```

This will create a `spot_nodegroups.yml` file that we will use to instruct eksctl to create two nodegroups, both with a diversified configuration.

```
eksctl create nodegroup -f spot_nodegroups.yml
```

{{% notice note %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these nodegroups.

 * We did set up **minSize** to 0, **maxSize** to 5 and **desiredCapacity** to 1. Nodegroups can be scaled down to 0.
 * We did set up **onDemandBaseCapacity** and **onDemandPercentageAboveBaseCapacity** both to **0**. which implies all nodes in the nodegroup would be **Spot instances**.
 * We did set up a **lifecycle: Ec2Spot** label so we can identify Spot nodes and use [affinities](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) and [nodeSelectors](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) later on.
 * We did specify **spotAllocationStrategy** pointing it to use **[Capacity Optimized](https://aws.amazon.com/about-aws/whats-new/2019/08/new-capacity-optimized-allocation-strategy-for-provisioning-amazon-ec2-spot-instances/)**. This will ensure the capacity we provision in our nodegroups is procured from the pools that will have less chances of being interrupted.
 * We did also add an extra label **intent: apps**. We will use this label to force a hard partition
 of the cluster for our applications. During this workshop we will deploy control applications on
 nodes that have been labeled with **intent: control-apps** while our applications get deployed to nodes labeled with **intent: apps**.
 * We are also applying a **[Taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)** using `spotInstance: "true:PreferNoSchedule"`.  **PreferNoSchedule** is used to indicate we prefer pods not be scheduled on Spot Instances. This is a “preference” or “soft” version of **NoSchedule** – the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required.
 * We did apply **k8s.io/cluster-autoscaler/node-template/label** and **k8s.io/cluster-autoscaler/node-template/taint** tags to the nodegroups. [This tags are used by cluster autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-scale-a-node-group-to-0) when nodegroups scale down to 0. They ensure cluster autoscaler considers tolerations and placement preferences of pending pods on nodegroups of 0 size.  

{{% notice info %}}
If you are wondering at this stage: *Where is spot bidding price ?* you are missing some of the changes EC2 Spot instances had since 2017. Since November 2017 [EC2 Spot price changes infrequently](https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/) based on long term supply and demand of spare capacity in each pool independently. You can still set up a **maxPrice** in scenarios where you want to set maximum budget. By default *maxPrice* is set to the On-Demand price; Regardless of what the *maxPrice* value, spot instances will still be charged at the current spot market price.
{{% /notice %}}

### Confirm the Nodes

{{% notice tip %}}
Aside from familiarizing yourself with the kubectl commands below to obtain the cluster information, you should also explore your cluster using **kube-ops-view** and find out the nodes that were just created.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see the nodes added to the cluster.

```bash
kubectl get nodes
```

You can use the node-labels to identify the lifecycle of the nodes

```bash
kubectl get nodes --show-labels --selector=lifecycle=Ec2Spot | grep Ec2Spot
```

The output of this command should return **Ec2Spot** nodes. At the end of the node output, you should see the node label **lifecycle=Ec2Spot**

![Spot Output](/images/using_ec2_spot_instances_with_eks/spotworkers/spot_get_spot.png)

Now we will show all nodes with the **lifecycle=OnDemand**. The output of this command should return OnDemand nodes (the ones that we tagged when
creating the cluster).

```bash
kubectl get nodes --show-labels --selector=lifecycle=OnDemand | grep OnDemand
```

![OnDemand Output](/images/using_ec2_spot_instances_with_eks/spotworkers/spot_get_od.png)

You can use the `kubectl describe nodes` with one of the spot nodes to see the taints applied to the EC2 Spot Instances.

![Spot Taints](/images/using_ec2_spot_instances_with_eks/spotworkers/instance_taints.png)

{{% notice note %}}
Explore your cluster using kube-ops-view and find out the nodes that have just been created.
{{% /notice %}}

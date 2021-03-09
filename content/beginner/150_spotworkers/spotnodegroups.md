---
title: "Add EC2 Workers - Spot"
date: 2021-03-08T10:00:00-08:00
weight: 10
draft: false
---
We have our EKS Cluster and nodes already, but we need some Spot Instances configured to run the workload. We will be creating managed nodegroup to utilize Spot Instances. We also need a Node Labeling strategy to identify which instances are Spot and which are On-Demand so that we can make more intelligent scheduling decisions. We will use `eksctl` to launch new worker nodes that will connect to the EKS cluster.

But first, we will add a new label to the On-Demand nodes

```bash
kubectl label nodes --all 'lifecycle=OnDemand'
```

#### Create Spot nodes

We are now ready to create Spot nodes.

```bash
eksctl create nodegroup --cluster=eksworkshop-eksctl --region=${AWS_REGION} --managed --spot --name=ng-spot --instance-types=m5.large,m4.large,m5d.large,m5a.large,m5ad.large,m5n.large,m5dn.large --node-labels="lifecycle=Ec2Spot"
```

During the creation of the Node Group, we have configured a **node-label** so that kubernetes knows what type of nodes we have provisioned. We set the **lifecycle** for the nodes as **Ec2Spot**. 

The node groups created follows Spot best practices including using [capacity-optimized](https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/) as the spotAllocationStrategy, which will launch instances from the Spot Instance pools with the most available capacity (out of the instance types we specified), aiming to decrease the number of Spot interruptions in our cluster (when EC2 needs the capacity back).

{{% notice info %}}
The creation of the nodes will take about 3 minutes.
{{% /notice %}}

#### Confirm the Nodes

Confirm that the new nodes joined the cluster correctly. You should see 2 more nodes added to the cluster.

```bash
kubectl get nodes --sort-by=.metadata.creationTimestamp
```

![All Nodes](/images/spotworkers/spot_get_nodes.png)
You can use the node-labels to identify the lifecycle of the nodes.

```bash
kubectl get nodes --label-columns=lifecycle --selector=lifecycle=Ec2Spot
```

The output of this command should return 2 nodes. At the end of the node output, you should see the node label **lifecycle=Ec2Spot**.

![Spot Output](/images/spotworkers/spot_get_spot.png)

Now we will show all nodes with the **lifecycle=OnDemand**. The output of this command should return multiple nodes as configured in `eksctl` YAMl template.

```bash
kubectl get nodes --label-columns=lifecycle --selector=lifecycle=OnDemand
```

![OnDemand Output](/images/spotworkers/spot_get_od.png)

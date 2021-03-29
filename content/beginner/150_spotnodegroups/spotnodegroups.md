---
title: "Add EC2 Spot Nodes"
date: 2021-03-08T10:00:00-08:00
weight: 10
draft: false
---
We have our EKS cluster and nodes already, but we need some Spot Instances configured to run the workload. We will be creating managed nodegroup to utilize Spot Instances. Managed nodegroups automatically creates a label - eks.amazonaws.com/capacityType - to identify which instances are Spot and which are On-Demand so that we can make more intelligent scheduling decisions. We will use `eksctl` to launch new spot nodes that will connect to the EKS cluster.

First, we can check that the current nodes are running On-Demand by checking the **eks.amazonaws.com/capacityType** label is set to **ON_DEMAND**.

```bash
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=ON_DEMAND
```

![OnDemand Output](/images/spotworkers/spot_get_od.png)

#### Create Spot nodes

We will not create the Spot nodegroup.

```bash
eksctl create nodegroup \
  --cluster=eksworkshop-eksctl --region=${AWS_REGION} \
  --managed --spot --name=ng-spot \
  --instance-types=m5.large,m4.large,m5d.large,m5a.large,m5ad.large,m5n.large,m5dn.large
```

{{% notice warning %}}
Note, the instances above might not be present in your region. To select instances that meet that criteria in your region, you could install [https://github.com/aws/amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector) and execute the command `ec2-instance-selector --base-instance-type m5.large --flexible` to get a diversified selection of instances available in your region of choice that meet the criteria of being similar to m4.large (in vCPU and memory terms)
{{% /notice %}}

Spot managed nodegroup creates a label **eks.amazonaws.com/capacityType** and sets it to **SPOT** for the nodes.

The node groups created follows Spot best practices including using [capacity-optimized](https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/) as the spotAllocationStrategy, which will launch instances from the Spot Instance pools with the most available capacity (when EC2 needs the capacity back), aiming to decrease the number of Spot interruptions in our cluster (when EC2 needs the capacity back).

{{% notice info %}}
The creation of the nodes will take about 3 minutes.
{{% /notice %}}

#### Confirm the Nodes

Confirm that the new nodes joined the cluster correctly. You should see 2 more nodes added to the cluster.

```bash
kubectl get nodes --sort-by=.metadata.creationTimestamp
```

![All Nodes](/images/spotworkers/spot_get_nodes.png)
You can use the **eks.amazonaws.com/capacityType** to identify the lifecycle of the nodes.

```bash
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=SPOT
```

The output of this command should return 2 nodes. At the end of the node output, you should see the node label **eks.amazonaws.com/capacityType=SPOT**.

![Spot Output](/images/spotworkers/spot_get_spot.png)



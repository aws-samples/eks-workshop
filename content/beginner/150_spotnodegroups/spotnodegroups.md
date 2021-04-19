---
title: "Add Spot managed node group"
date: 2021-03-08T10:00:00-08:00
weight: 10
draft: false
---
We have our EKS cluster and nodes already, but we need some Spot Instances configured to run the workload. We will be creating a Spot managed node group to utilize Spot Instances. Managed node groups automatically create a label - eks.amazonaws.com/capacityType - to identify which nodes are Spot Instances and which are On-Demand Instances so that we can schedule the appropriate workloads to run on Spot Instances. We will use `eksctl` to launch new nodes running on Spot Instances that will connect to the EKS cluster.

First, we can check that the current nodes are running On-Demand by checking the **eks.amazonaws.com/capacityType** label is set to **ON_DEMAND**. The output of the command shows the **CAPACITYTYPE** for the current nodes is set to **ON_DEMAND**.

```bash
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=ON_DEMAND
```

![OnDemand Output](/images/spotworkers/spot_get_od.png)

#### Create Spot managed node group

We will now create the a Spot managed node group using the --spot option in `eksctl create nodegroup` command.

```bash
eksctl create nodegroup \
  --cluster=eksworkshop-eksctl --region=${AWS_REGION} \
  --managed --spot --name=ng-spot \
  --instance-selector-vcpus=2 --instance-selector-memory=4
```

{{% notice %}}
The above command will automatically provision a node group with a list of instance types matching the instance selector resource criteria. At the time of this writing the list would consist of the following instance types: c5.large, c5a.large, c5ad.large, c5d.large, t2.medium, t3.medium, t3a.medium, but the set of instance types returned may change over time as new instance types are made available.

[Here](https://eksctl.io/usage/instance-selector) you can see more information about the instance selector.
{{% /notice %}}

Spot managed node group creates a label **eks.amazonaws.com/capacityType** and sets it to **SPOT** for the nodes.

The Spot managed node group created follows Spot best practices including using [capacity-optimized](https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/) as the spotAllocationStrategy, which will launch instances from the Spot Instance pools with the most available capacity (when EC2 needs the capacity back), aiming to decrease the number of Spot interruptions in our cluster.

{{% notice info %}}
The creation of the nodes will take about 3 minutes.
{{% /notice %}}

#### Confirm the Nodes

Confirm that the new nodes joined the cluster correctly. You should see 2 more nodes added to the cluster.

```bash
kubectl get nodes --sort-by=.metadata.creationTimestamp
```

![All Nodes](/images/spotworkers/spot_get_nodes.png)
You can use the **eks.amazonaws.com/capacityType** to identify the lifecycle of the nodes. The output of this command should return 2 nodes with the **CAPACITYTYPE** set to **SPOT**.

```bash
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=SPOT
```

![Spot Output](/images/spotworkers/spot_get_spot.png)



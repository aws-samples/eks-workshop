---
title: "Upgrade Managed Node Group"
weight: 324
---

Finally we have gotten to the last step of the upgrade process which is upgrading our Nodes.

There are two ways to provision and manage your worker nodes - self-managed node groups and managed node groups. In this workshop eksctl was configured to use the managed node groups. This was helpful here as managed node groups make this easier for us by automating both the AWS and the Kubernetes side of the process.

The way that managed node groups does this is:

1. Amazon EKS creates a new Amazon EC2 launch template version for the Auto Scaling group associated with your node group. The new template uses the target AMI for the update.
1. The Auto Scaling group is updated to use the latest launch template with the new AMI.
1. The Auto Scaling group maximum size and desired size are incremented by one up to twice the number of Availability Zones in the Region that the Auto Scaling group is deployed in. This is to ensure that at least one new instance comes up in every Availability Zone in the Region that your node group is deployed in.
1. Amazon EKS checks the nodes in the node group for the eks.amazonaws.com/nodegroup-image label, and applies a eks.amazonaws.com/nodegroup=unschedulable:NoSchedule taint on all of the nodes in the node group that aren't labeled with the latest AMI ID. This prevents nodes that have already been updated from a previous failed update from being tainted.
1. Amazon EKS randomly selects a node in the node group and evicts all pods from it.
1. After all of the pods are evicted, Amazon EKS cordons the node. This is done so that the service controller doesn't send any new request to this node and removes this node from its list of healthy, active nodes.
1. Amazon EKS sends a termination request to the Auto Scaling group for the cordoned node.
1. Steps 5-7 are repeated until there are no nodes in the node group that are deployed with the earlier version of the launch template.
1. The Auto Scaling group maximum size and desired size are decremented by 1 to return to your pre-update values.

{{% notice info %}}
If we instead had used a self-managed node group then we need to do the Kubernetes taint and draining steps ourselves to ensure Kubernetes knows that Node is going away and can manage that process gracefully in order for such an upgrade to be non-disruptive.
{{% /notice %}}

The first step only applies to if we are using the cluster autoscaler. We don't want conflicting Node scaling actions during our upgrade so we should scale that to zero to suspend it during this process using the command below. Unless you have done that chapter in the workshop and left it deployed you can skip this step.

```bash
kubectl scale deployments/cluster-autoscaler --replicas=0 -n kube-system
```

We can then trigger the MNG upgrade process by running the following eksctl command:
```bash
eksctl upgrade nodegroup --name=nodegroup --cluster=eksworkshop-eksctl --kubernetes-version=1.18
```

In another Terminal tab you can follow the progress with:
```bash
kubectl get nodes --watch
```
You'll notice the new nodes come up (three one in each AZ), one of the older nodes go STATUS SchedulingDisabled, then eventually that node go away and another new node come up to replace it and so on as described in the process above until all the old Nodes have gone away. Then it'll scale back down from 6 Nodes to the original 3.
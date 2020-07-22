---
title: "Scale a Cluster with CA"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

### Visualizing Cluster Autoscaler Logs and Actions 

{{% notice note %}}
During this section we recommend arranging your window so that you can see Cloud9 Console and Kube-ops-view and starting a new terminal in Cloud9 to tail Cluster Autoscaler logs. This will help you visualize the effect of your scaling commands.
{{% /notice %}}

{{%expand "Show me how to get kube-ops-view url" %}}
Execute the following command on Cloud9 terminal
```
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```
{{% /expand %}}


{{%expand "Show me how to tail Cluster Autoscaler logs" %}}
Execute the following command on Cloud9 terminal
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system --tail=10
```
{{% /expand %}}

### Scaling down to 0

Before we scale up our cluster let's explore what would happen when set up 0 replicas. 
Execute the following command: 

```
kubectl scale deployment/monte-carlo-pi-service --replicas=0
```

**Question:** Can you predict what would be the result of scaling down to 0 replicas ?

{{%expand "Show me the answer" %}}
The configuration that we applied to procure our nodegroups states that the minimum number of instances in the 
auto scaling group is 0 for both nodegroups. Starting from 1.14 version Cluster Autoscaler does support 
scaling down to 0. 

By setting the number of replicas to 0, Cluster Autoscaler will detect that the current instances are idle and can be removed. This may take up to 3 minutes. Cluster autoscaler will log lines such as the one below flagging that the instance is unneeded. 

```
I1120 00:22:37.204988       1 static_autoscaler.go:382] ip-192-168-54-241.eu-west-1.compute.internal is unneeded since 2019-11-20 00:21:16.651612719 +0000 UTC m=+4789.747568996 duration 1m20.552551794s
```

After some time, you should be able to confirm that running `kubectl get nodes` return only our 2 initial nodes:

```
$ kubectl get nodes
NAME                                           STATUS   ROLES    AGE   VERSION
ip-192-168-22-131.eu-west-1.compute.internal   Ready    <none>   46m   v1.14.7-eks-1861c5
ip-192-168-37-80.eu-west-1.compute.internal    Ready    <none>   46m   v1.14.7-eks-1861c5
```

{{% notice tip %}}
Check in the AWS console that both auto-scaling groups have now the Desired capacity set to 0. You can **[follow this link](https://console.aws.amazon.com/ec2/autoscaling/home?#AutoScalingGroups:filter=eksctl-eksworkshop-eksctl-nodegroup-dev;view=details)** to get into the Auto Scaling Group AWS console.
{{% /notice %}}



{{% /expand %}}



### Scale our ReplicaSet

OK, let's now scale out the replicaset to 3 
```
kubectl scale deployment/monte-carlo-pi-service --replicas=3
```

You can confirm the state of the pods using
```
kubectl get pods --watch
```

```
NAME                                     READY   STATUS    RESTARTS   AGE
monte-carlo-pi-service-584f6ddff-fk2nj   1/1     Running   0          20m21s
monte-carlo-pi-service-584f6ddff-fs9x6   1/1     Running   0          103s
monte-carlo-pi-service-584f6ddff-jst55   1/1     Running   0          103s
```
You should also be able to visualize the scaling action using kube-ops-view. Kube-ops-view provides an option to highlight pods meeting a regular expression. All pods in green are **monte-carlo-pi-service** pods.
![Scaling up to 10 replicas](/images/using_ec2_spot_instances_with_eks/scaling/scaling-kov-10-replicas.png)

{{% notice info %}}
Given we started from 0 capacity in both Ec2Spot nodegroups, this should trigger a scaling event for Cluster Autoscaler. Can you predict which size (and type!) of node will be provided ? 
{{% /notice %}}

#### Challenge

Try to answer the following questions:

 - Could you predict what should happen if we increase the number of replicas to 13 ? 
 - How would you scale up the replicas to 13 ? 
 - If you are expecting a new node, which size will it be: (a) 4vCPU's 16GB RAM or (b) 8vCPU's 32GB RAM ? 
 - Which AWS instance type you would expect to be selected ?
 - How would you confirm your predictions ?
 - Would you consider the selection of nodes by Cluster Autoscaler as optimal ? 

{{%expand "Show me the answers" %}}
To scale up the number of replicas run:
```
kubectl scale deployment/monte-carlo-pi-service --replicas=13
```

When the number of replicas scales up, there will be a few pods pending. You can confirm which pods are pending running the command below. 
```
kubectl get pods --watch
```

Kube-ops-view, will show 3 pending yellow pods outside the node.
![Scale Up](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-up-kov.png)

When inspecting cluster-autoscaler logs with the command line below 
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```
you will notice Cluster Autoscaler events similar to:
![CA Scale Up events](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-up2.png)


To confirm which type of node has been added you can either use kube-ops-view or execute:
```
kubectl get node --selector=intent=apps --show-labels
```

You can verify in AWS Management Console to confirm that the Auto Scaling groups are scaling up to meet demand. This may take a few minutes. You can also follow along with the pod deployment from the command line. You should see the pods transition from pending to running as nodes are scaled up.

![Scale Up](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-up.png)

{{% notice info %}}
Cluster Autoscaler expands capacity according to the [Expander](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) configuration. By default, Cluster Autoscaler uses the **random** expander. This means that there is equal probability of cluster autoscaler selecting the 4vCPUs 16GB RAM group or the 8vCPUs 32GB RAM group. You may consider also using other expanders like **least-waste**, or the **priority** expander.
{{% /notice %}}

As for the node that was selected, by default the Autoscaling Groups that we created with eksctl use [capacity-optimized allocation strategy](https://docs.aws.amazon.com/en_pv/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies), this makes the Auto Scaling Group procure capacity from the pools that has less chances of interruptions.  

{{% /expand %}}

After you've completed the exercise, scale down your replicas back down in preparation for the configuration of Horizontal Pod Autoscheduler.
```
kubectl scale deployment/monte-carlo-pi-service --replicas=3
```

{{% notice info %}}
It is a recommended to use **[capacity-optimized](https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/)** as an allocation strategy for your mixed instances EC2 Spot nodegroups. Other Strategies like *[Lowest Price](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html)* might be still considered for nodes that just process [Kubernetes retriable Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/)
{{% /notice %}}

### Optional Exercises

{{% notice warning %}}
Some of this exercises will take time for Cluster Autoscaler to scale up and down. If you are running this
workshop at a AWS event or with limited time, we recommend to come back to this section once you have 
completed the workshop, and before getting into the **cleanup** section.
{{% /notice %}}

 * At the moment AWS auto-scaling groups backing up the nodegroups are setup to use the [capacity-optimized allocation strategy](https://docs.aws.amazon.com/en_pv/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies). What do you think is the trade-off when you switch to [lowest price](https://docs.aws.amazon.com/en_pv/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies) allocation strategy ? 

 * What will happen when modifying Cluster Autoscaler **expander** configuration from **random**  to **least-waste**. What happens when we increase the replicas back to 13 ? What happens if we increase the number of replicas to 20? Can you predict which group of node will be expanded in each case: (a) 4vCPUs 16GB RAM (b) 8vCPUs 32GB RAM? What's Cluster Autoscaler log looking like in this case?

 * How would you expect Cluster Autoscaler to Scale in the cluster ? How about scaling out ? How much time you'll expect for it to take ?

 * How will pods be removed when scaling down? From which nodes they will be removed? What is the effect of adding [Pod Disruption Budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) to this mix ? 

 * Scheduling in Kubernetes is the process of binding pending pods to nodes, and is performed by a component of Kubernetes called [kube-scheduler](https://kubernetes.io/docs/concepts/scheduling/kube-scheduler/). When running on Spot the cluster is expected to be dynamic; the state is expected to change over time; The original scheduling decision may not be adequate after the state changes. Could you think or research for a project that could help address this? ([hint_1](https://github.com/kubernetes-sigs/descheduler)) [hint_2](https://github.com/pusher/k8s-spot-rescheduler). If so apply the solution and see what is the impact on scale-in operations.

 * During the workshop, we did use nodegroups that expand across multiple AZ's; There are scenarios where might create issues. Could you think which scenarios ? ([hint](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#common-notes-and-gotchas)). Could you think of ways of mitigating the risk in those scenarios ? ([hint 1](https://github.com/aws-samples/amazon-k8s-node-drainer), [hint 2](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#im-running-cluster-with-nodes-in-multiple-zones-for-ha-purposes-is-that-supported-by-cluster-autoscaler))


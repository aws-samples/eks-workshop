---
title: "Simulate the Interruption"
weight: 30
draft: false
---

Once you are able to see the nodes, we are ready to reduce the target capacity down by 1. This will trigger a Spot interruption notification. The Spot interrupt handler will see this notification and taint the node. Then pods will be moved and other ASGs will be scaled up by Cluster Autoscaler as needed.
 
Go to **Spot Requests**](https://eu-west-1.console.aws.amazon.com/ec2sp/v1/spot/home) in the EC2 Console. This will show you the open spot requests. Look at the request starting with *sfr-* This is the spot fleet request you would have created on the previous page.

Check the box next to the spot request and click on the **Actions** button above, and select **Modify Target Capacity** from the dropdown.
  
Change the capacity to **0** and confirm that **Terminate Instances** is checked. This will cause the SpotFleet to issue an interrupt to EC2 instance.

Click on the History tab of the spot fleet. You will notice that an interrupt will be issued to your instance. 

In your Cloud9 environment,  try the commands below every few seconds. You will see that the node is displayed as `SchedulingDisabled`. You will notice that the number of replicas are still running, just that they are just on different nodes.

```
kubectl get pods -o wide --sort-by='.status.hostIP'
```

```
kubectl get nodes  -o wide --show-labels 
```  
![Greeter pods on remaining nodes](/images/remainingspotpods.png)

### What has happened?

* The spot interrupt handler (running as daemon set) detected the interruption on EC2 instance launched by SpotFleet API.
* It issued a `kubectl drain` API command
* Kubernetes has reassigned the running pods elsewhere in cluster and your application is still running desired replicas.

### Clean up the Spot Fleet
Go to **Spot Requests**](https://eu-west-1.console.aws.amazon.com/ec2sp/v1/spot/home) in the EC2 Console. 

Check the box next to the spot request and click on the **Actions** button above, and select **Cancel Spot Request** from the dropdown.



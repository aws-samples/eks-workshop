---
title: "Provision EC2 Spot worker using Spot Fleet API"
chapter: true
weight: 2
draft: false
---

1. Login to AWS Console, and navigate to *Services* -> *EC2*. 

2. In the left hand menu bar, choose *Spot Requests* .

3. Click on *Request Spot Instances* buttn

4. Leave the default choice of *Request*, and leave Total target capacity to 1. We will make this to 0 to cause Spot Fleet to send an interruption to EC2 instance.

5. Leave the AMI, adjust the instance type to a t2.micro (preferably), and choose the *VPC* to be the same one as the one that our EKS Cluster is created in.

6. Update the *Instance tags* to reflect below values. These instance tags ensure that when the EC2 instances are launched by SpotFleet API, they are discoverable and join the EKS cluster control plane endpoint for the cluster you created earlier.

![Instance tags](/images/InstanceTags.PNG)

7.  Wait for few minutes (about 8-10), and check from command line if you are able to see these newly added EC2 instances as part of cluster launched by SpotFleet API by using command below

Important: Make sure the instances have the correct Public IP address, security group for worker nodes, and the IAM Role attached along with tags as mentioned above. Only then you are able to see the worker node as part of the EKS cluster 

```
kubectl get nodes 
```

8. Now let's scale up the greeter app and watch the pods getting placed on newly added EC2 Instance using SpotFleet API.

```
kubectl scale --replicas=3 deployment/greeter
```

Tip: If you scale down all of the EC2 Spot instances down to just 3, you can watch this interruption and reassignment very easily with a low-number of replicas.

You can do this by setting by only keeping one of your ASG SpotNodeGroups desired and min values to 1, and the rest to zero.

This will prepare your environment with only 1 EC2 Spot instance launched via ASG/Launch Configuration API, and the other one with SpotFleet API.

9. Check if the pods are placed
```
kubectl get pods -o wide --sort-by='.status.hostIP'
```

![PodsOnSpotNodes](/images/podsonspot.PNG)

Now, you are ready to create an interruption.
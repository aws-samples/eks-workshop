---
title: "Deploy EC2 Spot worker using Spot Fleet API"
weight: 10
draft: false
---

We will simulate a spot interruption by triggering the Spot API to scale down a group of instance. This is not possible with the EC2 Autoscaling groups that we have been using thus far. We will by creating a new [**Spot Fleet**](https://docs.aws.amazon.com/cli/latest/reference/ec2/request-spot-fleet.html) request and add these workers to our cluster. We will deploy pods to these nodes and then remove capacity from the fleet triggering a notification.

Spot interruption notifications are reported in the following ways:


 * In the EC2 instance, using the [EC2 metadata service](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)
 * In the AWS account, using [CloudWatch Events](https://aws.amazon.com/about-aws/whats-new/2018/01/amazon-ec2-spot-two-minute-warning-is-now-available-via-amazon-cloudwatch-events/)

Login to [**AWS EC2 Console**](https://console.aws.amazon.com/ec2)

In the left hand menu bar, choose **Spot Requests**

Click on **Request Spot Instances** button

{{% notice info %}}
The Amazon EC2 Spot Console was updated on 11/20/2018 to [simplify the user flow and provide Spot Fleet recommendations.](https://aws.amazon.com/about-aws/whats-new/2018/11/new-simplified-user-flow-and-fleet-recommendations-available-in-amazon-ec2-spot-console/) As a result, some of the prompts referenced below have changed. We will be updating the instructions soon. In the meantime, please refer to the [Spot documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet-requests.html#create-spot-fleet) for more information.
{{% /notice %}}

Leave the default choice of `Request and Maintain`, and leave `Total target capacity` to **1**. (Later, we'll reduce this to **0** to cause Spot Fleet to send an interruption to EC2 instance)

Provide the [**EKS-Optimized ami-id**](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) that you used in your CloudFormation Template

Change the instance type to a `t2.micro`

Choose the `VPC` for the EKS Workshop. Select each AZ. The subnets should be auto-populated

Under `Security Groups`, select the one Named EKSWorkshop and nodegroup0

For `Auto-assign IPv4 Public IP`, select **Enable**

Select the `keypair` named eksworkshop

Select the `IAM Instance Profile` beginning with **EKSWorkshop-nodegroup0**

In the UserData section paste the following script:
```
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh eksworkshop --kubelet-extra-args --node-labels=lifecycle=Ec2Spot
```

Update the `Instance tags` to reflect below values. These instance tags ensure that when the EC2 instances are launched by SpotFleet API, they are discoverable and join the EKS cluster control plane endpoint for the cluster you created earlier.

| Key | Value |
|-----------|-------|
| Name | EKSSpot-SpotFleet-Node |
| kubernetes.io/cluster/eksworkshop | owned |
| k8s.io/cluster-autoscaler/enabled | true |
| Spot | true|

Wait for few minutes (about 8-10). Check from command line if you are able to see these newly added EC2 instances as part of cluster launched by SpotFleet API by using command below.  Look at the Age column to identify the new node. Take note of the name as you will want to confirm that pods are placed on this instance in the next step.

```
kubectl get nodes
```
{{% notice info %}}
If you don't see your nodes joining the cluster, make sure the instances have the correct Public IP address, security group for worker nodes, and the IAM Role attached along with tags as mentioned above. Only then will they able to join the cluster. Compare to existing worker nodes if you have doubts.
{{% /notice %}}

Now let's scale up the app we used previously with Cluster Autoscaler and watch the pods getting placed on newly added EC2 Instance using SpotFleet API.
```
kubectl scale --replicas=10 deployment/nginx-to-scaleout
```

If you change the settings of all of the EC2 Spot instances ASGs, you can watch this interruption and reassignment very easily with a low-number of replicas. You can do this by setting one of your SpotNodeGroups ASG desired and min values to **1** and the rest to zero.

This will prepare your environment with only 1 EC2 Spot instance launched via ASG/Launch Configuration API, and the other one with SpotFleet API.

Check if the pods are placed
```
kubectl get pods -o wide --sort-by='.status.hostIP'
```

![PodsOnSpotNodes](/images/podsonspot.png)

#### Now we are ready to create an interruption
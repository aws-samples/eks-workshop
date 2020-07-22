---
title: "Configure Cluster Autoscaler (CA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

We will start by deploying [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler). Cluster Autoscaler for AWS provides integration with Auto Scaling groups. It enables users to choose from four different options of deployment:

* One Auto Scaling group 
* Multiple Auto Scaling groups
* **Auto-Discovery** - This is what we will use
* Master Node setup

In this workshop we will configure Cluster Autoscaler to scale using **[Cluster Autoscaler Auto-Discovery functionality](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md)**. When configured in Auto-Discovery mode on AWS, Cluster Autoscaler will look for Auto Scaling Groups that match a set of pre-set AWS tags. As a convention we use the tags : `k8s.io/cluster-autoscaler/enabled`, and `k8s.io/cluster-autoscaler/eksworkshop-eksctl` .

This will select the two Auto Scaling groups that have been created for Spot instances.

{{% notice note %}}
The  **[following link](https://console.aws.amazon.com/ec2/autoscaling/home?#AutoScalingGroups:filter=eksctl-eksworkshop-eksctl-nodegroup-dev;view=details)** Should take you to the
Auto Scaling Group console and select the two spot node-group we have previously created; You should check that
the tags `k8s.io/cluster-autoscaler/enabled`, and `k8s.io/cluster-autoscaler/eksworkshop-eksctl` are present 
in both groups. This has been done automatically by **eksctl** upon creation of the groups.
{{% /notice %}}

We have provided a manifest file to deploy the CA. Copy the commands below into your Cloud9 Terminal. 

```
mkdir -p ~/environment/cluster-autoscaler
curl -o ~/environment/cluster-autoscaler/cluster_autoscaler.yml https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/using_ec2_spot_instances_with_eks/scaling/deploy_ca.files/cluster_autoscaler.yml
sed -i "s/--AWS_REGION--/${AWS_REGION}/g" ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

### Deploy the Cluster Autoscaler

{{% notice info %}}
You are encouraged to look at the configuration that you downloaded for cluster autoscaler in the directory `cluster-autoscaler` and find out about some of the parameter we are passing to it. The full list of parameters can be found in **[Cluster Autoscaler documentation](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca)**. 
{{% /notice %}}

Cluster Autoscaler gets deployed like any other pod. In this case we will use the **[kube-system namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)**, similar to what we do with other management pods.

```
kubectl apply -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

To watch Cluster Autoscaler logs we can use the following command:
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system --tail=10
```

#### We are now ready to scale our cluster !!

{{%attachments title="Related files" pattern=".yml"/%}}

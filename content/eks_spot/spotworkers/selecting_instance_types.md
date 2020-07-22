---
title: "Selecting Instance Types"
date: 2018-08-07T11:05:19-07:00
weight: 10
draft: false
---

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

One of the best practices to successfully adopt Spot instances is to implement **Spot instance diversification** as part of your configuration. Spot instance diversification helps to procure
capacity from multiple Spot Instance pools, both for scaling up and for replacing spot instances that may receive a spot instance termination notification. A Spot instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone.

### Cluster Autoscaler And Spot Instance Diversification

Cluster Autoscaler is a tool that automatically adjusts the size of the Kubernetes cluster when there are pods that fail to run in the cluster due to insufficient resources (Scale Out) or there are nodes in the cluster that have been underutilized for a period of time (Scale In).

{{% notice info %}}
When using Spot instances with [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) there are a few things that [should be considered](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md). For example Cluster Autoscaler makes the assumption that all nodes within a nodegroup will have the same number of vCPUs and Memory.
{{% /notice %}}

When applying Spot Diversification best practices to EKS and K8s clusters, using Cluster Autoscaler to dynamically scale capacity, we must implement diversification in a way that adheres to Cluster Autoscaler expected operational mode. In this workshop we will assume that our cluster nodegroups should be provisioned with instance types that adhere to a 1vCPU:4GB RAM ratio.

We can diversify Spot instance pools using two strategies:

 - By creating multiple nodegroups, each of different sizes. For example a nodegroup of size 4VCPU's and 16GB Ram, and another nodegroup of 8vCPU's and 32GB Ram. 
 
 - By Implementing instance diversification within the nodegroups, by selecting a mix of instances types and families from different Spot instance pools that meet the same vCPU's and memory criteria.

Our goal in this workshop, is to create at least 2 diversified groups of instances that adhere the 1vCPU:4GB RAM ratio. 

We will use **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** to help us select the relevant instance
types and familes with sufficient number of vCPUs and RAM. 

There are over 270 different instance types available on EC2 which can make the process of selecting appropriate instance types difficult. **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** helps you select compatible instance types for your application to run on. The command line interface can be passed resource criteria like vcpus, memory, network performance, and much more and then return the available, matching instance types.

Let's first install **amazon-ec2-instance-selector** :

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v1.3.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run
`ec2-instance-selector --help` to understand how you could use it for selecting
instances that match your workload requirements. For the purpose of this workshop
we need to first get a group of instances that meet the 4vCPUs and 16GB of RAM.
Run the following command to get the list of instances.

```bash
ec2-instance-selector --vcpus 4 --memory 16384 --gpus 0 --current-generation -a x86_64 --deny-list '.*n.*'      
```

This should display a list like the one that follows (note results might differ depending on the region). We will use this instances as part of one of our node groups.

```
m4.xlarge
m5.xlarge
m5a.xlarge
m5d.xlarge
t2.xlarge
t3.xlarge
t3a.xlarge           
```

Internally ec2-instance-selector is making calls to the [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) for the specific region and filtering
the intstances based on the criteria selected in the command line, in our case 
we did filter for instances that meet the following criteria:
 * Instances with no GPUs
 * of x86_64 Architecture (no ARM instances like A1 or m6g instances for example)
 * Instances that have 4 vCPUs and 16GB of Ram
 * Instances of current generation (4th gen onwards)
 * Instances that don't meet the regular expresion `.*n.*`, so effectively m5n, m5dn. 

{{% notice warning %}}
Your workload may have other constraints that you should consider when selecting instances types. For example. **t2** and **t3** instance types are [burstable instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances.html) and might not be appropriate for CPU bound workloads that require CPU execution determinism. Instances such as m5**a** are [AMD Instances](https://aws.amazon.com/ec2/amd/), if your workload is sensitive to numerical differences (i.e: financial risk calculations, industrial simulations) mixing these instance types might not be appropriate.
{{% /notice %}}

{{% notice note %}}
You are encouraged to test what are the options that `ec2-instance-selector` provides and run a few commands with it to familiarize yourself with the tool.
For example, try running the same commands as you did before with the extra parameter **`--output table-wide`**.
{{% /notice %}}

### Challenge 

Find out another group that adheres to a 1vCPU:4GB ratio, this time using instances with 8vCPU's and 32GB of RAM.

{{%expand "Expand this for an example on the list of instances" %}}

That should be easy. You can run the command:  

```bash
ec2-instance-selector --vcpus 8 --memory 32768 --gpus 0 --current-generation -a x86_64 --deny-list '.*n.*|.*h.*'   
```

which should yield a list as follows 

```
m4.2xlarge
m5.2xlarge
m5a.2xlarge
m5d.2xlarge
t2.2xlarge
t3.2xlarge
t3a.2xlarge
```

{{% /expand %}}





---
title: "Using Spot Instances Part 1 - Setup"
date: 2021-05-11T13:38:18+08:00
weight: 50
draft: false
---

### EC2 Spot Instances

Amazon EC2 Spot Instances let you take advantage of unused EC2 capacity in the AWS cloud. Spot Instances are available at up to a 90% discount compared to On-Demand prices. You can use Spot Instances for various stateless, fault-tolerant, or flexible applications such as big data, containerized workloads, CI/CD, web servers, high-performance computing (HPC), and test & development workloads.
[Click here](https://aws.amazon.com/ec2/spot/) to know more about Spot Instances.

### EKS Managed Node Groups with Spot Instances

Previously on [EMR on EKS Prerequisites](/advanced/430_emr_on_eks/prereqs/#create-eks-managed-node-group), you created managed node group named **emrnodegroup** with On-Demand Instances. Now you will be creating another managed node group with Spot Instances.  
Managed node groups automatically create a label - `eks.amazonaws.com/capacityType` - to identify which nodes are Spot Instances and which are On-Demand Instances. We will use this label to schedule the appropriate workloads to run on Spot Instances.

{{% notice info %}}
Refer this [deep dive blog](https://aws.amazon.com/blogs/containers/amazon-eks-now-supports-provisioning-and-managing-ec2-spot-instances-in-managed-node-groups/) to learn the best practices you need to follow to provision, manage and maintain EKS managed node groups with Spot Instances.
{{% /notice %}}


### Create a Managed Node Group with Spot Instances

To maximize the availability of your applications while using Spot Instances, we recommend that you configure a managed node group to use multiple instance types. When selecting what instance types to use, you can look to all instance types that supply a certain amount of vCPUs and memory to the cluster, and group those in each node group.
For example, a single node group can be configured with: **m5**.xlarge, **m4**.xlarge, **m5a**.xlarge, **m5d**.xlarge, **m5ad**.xlarge, **m5n**.xlarge, and **m5dn**.xlarge. These instance types supply almost identical vCPU and memory capacity, which is important in order for Kubernetes cluster autoscaler to efficiently scale the node groups.

{{% notice tip %}}
[EC2 Instance Selector](https://github.com/aws/amazon-ec2-instance-selector) is an open source tool that can help you find suitable instance types with a single CLI command. 
{{% /notice %}}


We will now create a managed node group with Spot Instances, let's create a config file (addnodegroup-spot.yaml) with details of a new managed node group. 

```sh
cat << EOF > addnodegroup-spot.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

managedNodeGroups:
- name: emrnodegroup-spot
  minSize: 1
  desiredCapacity: 3
  maxSize: 10
  instanceTypes: ["m5.xlarge","m4.xlarge","m5d.xlarge","m5n.xlarge","m5dn.xlarge","m5a.xlarge","m5ad.xlarge"]
  spot: true
  ssh:
    enableSsm: true

EOF
```
Create the new EKS managed nodegroup with Spot Instances. 

```sh
eksctl create nodegroup --config-file=addnodegroup-spot.yaml
```
{{% notice info %}}
Creation of node group will take 3-4 minutes. 
{{% /notice %}}

You can use the **eks.amazonaws.com/capacityType** label to identify the lifecycle of the nodes. The output of this command should return nodes with the **capacityType** set to **SPOT**.

```bash
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=SPOT
```
{{% notice info %}}
You can review the dedicated chapter on Spot Instances  [SPOT CONFIGURATION AND LIFECYCLE
](/beginner/150_spotnodegroups/spotlifecycle/) to learn more about how EKS managed node groups handle Spot Interruption automatically.
{{% /notice %}}
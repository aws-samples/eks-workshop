---
title: "CNI configuration"
date: 2020-12-02T21:30:00-05:00
draft: false
weight: 30
tags:
  - beginner
---

To enable this new functionality, Amazon EKS clusters have two new components running on the Kubernetes control plane:

* A **mutating webhook** responsible for adding limits and requests to pods requiring security groups.
* A **resource controller** responsible for managing [network interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) associated with those pods.

To facilitate this feature, each worker node will be associated with a single trunk network interface, and multiple branch network interfaces. The trunk interface acts as a standard network interface attached to the instance. The VPC resource controller then associates branch interfaces to the trunk interface. This increases the number of network interfaces that can be attached per instance. Since security groups are specified with network interfaces, we are now able to schedule pods requiring specific security groups onto these additional network interfaces allocated to worker nodes.

First we need to attach a new IAM policy the Node group role to allow the EC2 instances to manage network interfaces, their private IP addresses, and their attachment and detachment to and from instances.

The following command adds the policy `AmazonEKSVPCResourceController` to a cluster role.

```bash
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController \
    --role-name ${ROLE_NAME}
```

Next, we will enable the CNI plugin to manage network interfaces for pods by setting the `ENABLE_POD_ENI` variable to true in the aws-node `DaemonSet`.

```bash
kubectl -n kube-system set env daemonset aws-node ENABLE_POD_ENI=true

# let's way for the rolling update of the daemonset
kubectl -n kube-system rollout status ds aws-node
```

Once this setting is set to true, for each node in the cluster the plugin adds a label with the value `vpc.amazonaws.com/has-trunk-attached=true` to the compatible instances. The VPC resource controller creates and attaches one special network interface called a trunk network interface with the description aws-k8s-trunk-eni.

```bash
 kubectl get nodes \
  --selector alpha.eksctl.io/nodegroup-name=nodegroup-sec-group \
  --show-labels
```

![sg-per-pod_4](/images/sg-per-pod/sg-per-pod_4.png)

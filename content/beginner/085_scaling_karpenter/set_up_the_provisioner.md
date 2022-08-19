---
title: "Set up the Provisioner"
weight: 30
draft: false
---


## Setting up a simple (default) CRD Provisioner

Karpenter configuration comes in the form of a Provisioner CRD (Custom Resource Definition).
A single Karpenter provisioner is capable of handling many different pod shapes. Karpenter makes scheduling and provisioning decisions based on pod attributes such as labels and affinity. A cluster may have more than one Provisioner, but for the moment we will declare just one: the default Provisioner. 

One of the main objectives of Karpenter is to simplify the management of capacity. If you are familiar with other Auto Scalers, you will notice Karpenter takes a different approach. You may have heard the approached referred as **group-less auto scaling**. Other Solutions have traditionally used the concept of a **node group** as the element of control that defines the characteristics of the capacity provided (i.e: On-Demand, EC2 Spot, GPU Nodes, etc) and that controls the desired scale of the group in the cluster. In AWS the implementation of a node group matches with [Auto Scaling groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html). Over time, clusters using this paradigm, that run different type of applications requiring different capacity types, end up with a complex configuration and operational model where node groups must be defined and provided in advance. 


Let's deploy the following configuration:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  labels:
    intent: apps
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot"]
    - key: karpenter.k8s.aws/instance-size
      operator: NotIn
      values: [nano, micro, small, medium, large]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  ttlSecondsAfterEmpty: 30
  ttlSecondsUntilExpired: 2592000
  providerRef:
    name: default
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    alpha.eksctl.io/cluster-name: ${CLUSTER_NAME}
  securityGroupSelector:
    alpha.eksctl.io/cluster-name: ${CLUSTER_NAME}
  tags:
    KarpenerProvisionerName: "default"
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
EOF

```

The configuration for the provider is split into two parts. The first one defines the provisioner relevant spec. The second part is defined by the provider implementation, in our case `AWSNodeTemplate` and defines the specific configuration that applies to that cloud provider. The Provisioner configuration is quite simple. During the workshop we will change the Provisioner and even use multiple provisioners. For the moment let's focus in a few of the settings used.

* **Requirements Section**: The [Provisioner CRD](https://karpenter.sh/docs/provisioner-crd/) supports defining node properties like instance type and zone. For example, in response to a label of topology.kubernetes.io/zone=us-east-1c, Karpenter will provision nodes in that availability zone. In this example we are setting the `karpenter.sh/capacity-type` to procure EC2 Spot instances, and  `karpenter.k8s.aws/instance-size` to avoid smaller instances. You can learn which other properties are [available here](https://karpenter.sh/v0.15.0/tasks/scheduling/#selecting-nodes). We will work on a few more during the workshop.
* **Limits section**: Provisioners can define a limit in the number of CPU's and memory allocated to that particular provisioner and part of the cluster.
* **Provider section**: This provisioner uses `securityGroupSelector` and `subnetSelector` to discover resources used to launch nodes. It uses the tags that Karpenter attached to the subnets.
* **ttlSecondsAfterEmpty**: value configures Karpenter to terminate empty nodes. This behavior can be disabled by leaving the value undefined. In this case we have set it for a quick demonstration to a value of 30 seconds.
* **ttlSecondsUntilExpired**: optional parameter. When set it defines when a node will be deleted. This is useful to force new nodes with up to date AMI's. In this example we have set the value to 30 days.
* **Tags**: Provisioners can also define a set of tags that the EC2 instances will have upon creation. This helps to enable accounting and governance at the EC2 level. As you can see this is done through as part of the provider section.

{{% notice info %}}
Karpenter has been designed to be generic and support other Cloud and Infrastructure providers. At the moment of writing this workshop (Karpenter 0.15.0) main implementation and Provisioner available is on AWS. You can read more about the **[configuration available for the AWS Provisioner here](https://karpenter.sh/docs/aws/)**
{{% /notice %}}

## Displaying Karpenter Logs

{{% notice tip %}}
You can create a new terminal window within Cloud9 and leave the command below running so you can come back to that terminal every time you want to look for what Karpenter is doing.
{{% /notice %}}

To read Karpenter logs from the console you can run the following command.

```bash
kubectl logs -f deployment/karpenter-controller -n karpenter
```

{{% notice info %}}
Karpenter log configuration is stored as a Kubernetes ConfigMap. You can read the configuration by running the following command: 
`kubectl describe configmap config-logging -n karpenter`.
You can increase the logging level to `debug` using the following command: 
`kubectl patch configmap config-logging -n karpenter --patch '{"data":{"loglevel.controller":"debug"}}'`
{{% /notice %}}
---
title: "Setting up Jenkins agents"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

We now have our Jenkins Master running inside our EKS cluster, and we can reach the Jenkins dashboard via an ELB. We can create jobs which will be executed by Jenkins agents in pods within our cluster, but before we do that, let's create a dedicated Spot based nodegroup for our Jenkins agents, which will be slightly different from our existing nodegroups. 

#### Creating a new Spot Instances nodegroup for our Jenkins agent pods
Earlier in the workshop, in the **Adding Spot Workers with eksctl** step, we created nodegroups that run a diversified set of Spot Instances to run our applications.Let's create a new eksctl nodegroup configuration file called `spot_nodegroup_jenkins.yml`. The Jenkins default resource requirements (Request and Limit CPU/Memory) are 512m (~0.5 vCPU) and 512Mi (~0.5 GB RAM), and since we are not going to perform any large build jobs in this workshop, we can stick to the defaults and also choose relatively small instance types that can accommodate the Jenkins agent pods.

```
cat <<EoF > ~/environment/spot_nodegroup_jenkins.yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl
    region: $AWS_REGION
nodeGroups:
    - name: jenkins-agents-2vcpu-8gb-spot
      minSize: 0
      maxSize: 5
      desiredCapacity: 1
      instancesDistribution:
        instanceTypes: ["m5.large", "m5d.large", "m4.large","t3.large","t3a.large","m5a.large","t2.large"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotAllocationStrategy: capacity-optimized
      labels:
        lifecycle: Ec2Spot
        intent: jenkins-agents
        aws.amazon.com/spot: "true"
      tags:
          k8s.io/cluster-autoscaler/node-template/label/lifecycle: Ec2Spot
          k8s.io/cluster-autoscaler/node-template/label/intent: jenkins-agents
          k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot: "true"
EoF
```

This will create a `spot_nodegroup_jenkins.yml` file that we will use to instruct eksctl to create one nodegroup (EC2 Auto Scaling group), with the labels `intent: jenkins-agents` and `lifecycle: Ec2Spot`. The ASG will also have a custom tag key `k8s.io/cluster-autoscaler/node-template/label/intent` with the value `jenkins-agents` - This is in order for Kubernetes cluster-autoscaler to respect the node selector configuration that we will apply later in the module.

Since Jenkins job oriented workloads are not fault-tolerant and an EC2 Spot interruption would cause the build job to fail, we can choose the **capacity-optimized** allocation strategy which will provision Spot Instances for us from the capacity pools that have the lowest chances of being interrupted. This way, we increase the chances of successfully completing our Jenkins jobs when running on Spot Instances.

```
eksctl create nodegroup -f spot_nodegroup_jenkins.yml
```

{{% notice note %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}


#### Instructing Jenkins to run jobs on the new, Spot dedicated nodegroup
1. In  the Jenkins dashboard, browse to **Manage Jenkins** -> **Manage Node and Clouds**
1. On the left hand side click on the **Configure Clouds** link. That will take you to the cloud configuration where Kubernetes.
1. Click on the **Pod Templates...** button to expand the default pod template definition  and then click again on **Pod Template Details...*** 
1. Change the default pod name, attribute **Name** from `defualt` to `jenkins-agent`. We want to be able to identify the pods that are running in our clusters by name. 
![Jenkins Pod Setup 1](/images/using_ec2_spot_instances_with_eks/jenkins/jenkinslabels-1.png)
1. At the bottom of the page, near the end of the Pod template section, In the **Node Selector** Pod , add the following: `intent=jenkins-agents,lifecycle=Ec2Spot`
![Jenkins Pod Setup 2](/images/using_ec2_spot_instances_with_eks/jenkins/jenkinslabels-2.png)
1. Click **Save**

Now, when Jenkins creates new pods (=agents), these will be created with a Node Selector that instructs the kube-scheduler to only deploy the pods on nodes with the above mentioned labels, which only exist in the dedicated Jenkins nodegroup.


Move to the next step in the workshop to learn how to increase the resilience of your Jenkins jobs.

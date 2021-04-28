---
title: "Add Nodegroup"
date: 2020-01-27T08:30:11-07:00
weight: 21
draft: false
---


#### Create new Managed Nodegroup

Looking at the [clusterconfig.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/clusterconfig.yaml), you can see the Nodegroup setup is using our existing cluster `eksworkshop-eksctl`.

{{< output >}}
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

managedNodeGroups:
  - name: prodcatalog-demo-ng
    minSize: 2
    maxSize: 3
    desiredCapacity: 3
    volumeSize: 20
    labels: {role: ctrl-workers}
    tags:
      nodegroup-role: ctrl-workers
    iam:
      withAddonPolicies:
        appMesh: true
        xRay: true
        cloudWatch: true
{{< /output >}}

Run the below command "eksctl create nodegroup" which will create new Nodegroup named `prodcatalog-demo-ng` and will also create 
the other resources like NodeInstanceRole, CloudWatchAgentServer Inline-Policy, AppMesh Inline-Policy, and XRay Inline-Policy.

```bash
envsubst < ./deployment/clusterconfig.yaml | eksctl create nodegroup -f -
```

{{< output >}}
[ℹ]  eksctl version 0.36.2
[ℹ]  using region us-west-2
[ℹ]  will use version 1.17 for new nodegroup(s) based on control plane version
[ℹ]  1 existing nodegroup(s) (nodegroup) will be excluded
[ℹ]  1 nodegroup (prodcatalog-demo-ng) was included (based on the include/exclude rules)
[ℹ]  will create a CloudFormation stack for each of 1 managed nodegroups in cluster "eksworkshop-eksctl"
[ℹ]  2 sequential tasks: { fix cluster compatibility, 1 task: { 1 task: { create managed nodegroup "prodcatalog-demo-ng" } } }
[ℹ]  checking cluster stack for missing resources
[ℹ]  cluster stack is missing resources for Fargate
[ℹ]  adding missing resources to cluster stack
[ℹ]  re-building cluster stack "eksctl-eksworkshop-eksctl-cluster"
[ℹ]  updating stack to add new resources [FargatePodExecutionRole] and outputs [FargatePodExecutionRoleARN]
[ℹ]  waiting for CloudFormation changeset "eksctl-update-cluster-1611896537" for stack "eksctl-eksworkshop-eksctl-cluster"
[ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-cluster"
[ℹ]  building managed nodegroup stack "eksctl-eksworkshop-eksctl-nodegroup-prodcatalog-demo-ng"
[ℹ]  deploying stack "eksctl-eksworkshop-eksctl-nodegroup-prodcatalog-demo-ng"
[ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-nodegroup-prodcatalog-demo-ng"
[ℹ]  no tasks
[✔]  created 0 nodegroup(s) in cluster "eksworkshop-eksctl"
[ℹ]  nodegroup "prodcatalog-demo-ng" has 3 node(s)
[ℹ]  node "ip-192-168-30-XXX.us-west-2.compute.internal" is ready
[ℹ]  node "ip-192-168-XX-1YY.us-west-2.compute.internal" is ready
[ℹ]  node "ip-192-168-Z6-1XY.us-west-2.compute.internal" is ready
[ℹ]  waiting for at least 2 node(s) to become ready in "prodcatalog-demo-ng"
[ℹ]  nodegroup "prodcatalog-demo-ng" has 3 node(s)
[ℹ]  node "ip-192-168-30-XXX.us-west-2.compute.internal" is ready
[ℹ]  node "ip-192-168-XX-1YY.us-west-2.compute.internal" is ready
[ℹ]  node "ip-192-168-Z6-1XY.us-west-2.compute.internal" is ready
[✔]  created 1 managed nodegroup(s) in cluster "eksworkshop-eksctl"
[ℹ]  checking security group configuration for all nodegroups
[ℹ]  all nodegroups have up-to-date configuration
{{< /output >}}

{{% notice info %}}
The creation of the Nodegroup will take about 5 - 7 minutes.
{{% /notice %}}

#### Confirm Nodegroup setup

Confirm that the new nodes joined the cluster correctly. You should see last 3 nodes added to the cluster.

```bash
kubectl get nodes --sort-by=.metadata.creationTimestamp
```
{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-168-SS-1WW.us-west-2.compute.internal   Ready    <none>   4m16s   v1.17.12-eks-7684af
ip-192-168-PP-2PS.us-west-2.compute.internal   Ready    <none>   4m14s   v1.17.12-eks-7684af
ip-192-168-7S-1PP.us-west-2.compute.internal   Ready    <none>   4m9s    v1.17.12-eks-7684af
ip-192-168-30-XXX.us-west-2.compute.internal   Ready    <none>   4h2m    v1.17.12-eks-7684af 
ip-192-168-XX-1YY.us-west-2.compute.internal   Ready    <none>   4h2m    v1.17.12-eks-7684af
ip-192-168-Z6-1XY.us-west-2.compute.internal   Ready    <none>   4h1m    v1.17.12-eks-7684af
{{< /output >}}

Log into console and navigate to Amazon EKS -> Cluster -> Click `eksworkshop-eksctl` -> Configuration -> Compute, you should see the new Nodegroup `prodcatalog-demo-ng` you created:
![nodegroup](/images/app_mesh_fargate/eks-nodegroup1.png)

Click on the Nodegroup `prodcatalog-demo-ng` you will see the below information about NodeInstance Role.
![instancerole](/images/app_mesh_fargate/instancerole.png)

Click on the NodeInstance Role and you will be navigated to IAM page where you will see the below polcies added to the Nodes in Nodegroup. These polcies are required for Nodegroup to access App Mesh, X-Ray, and Cloudwatch that were added as part of Nodegroup creation.
![policies](/images/app_mesh_fargate/policies.png)

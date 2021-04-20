---
title: "Prereqs"
date: 2021-5-01T09:00:00-00:00
weight: 5
draft: false
---

### Add a node group

First, we need to accommodate the pods that we're about to deploy for Pixie and our microservices demo application. We will add a managed node group to scale the `eksworkshop-eksctl` cluster.

Create a node group config file by running:

```bash
cat << EOF > clusterconfig.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

# https://eksctl.io/usage/eks-managed-nodegroups/
managedNodeGroups:
  - name: pixie-demo-ng
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

# https://eksctl.io/usage/iamserviceaccounts/
iam:
  withOIDC: true
  serviceAccounts:
    - metadata:
        name: pixie-demo-sa
        namespace: pixie-demo-ns
        labels: {aws-usage: "application"}
      attachPolicyARNs:
        - "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
        - "arn:aws:iam::aws:policy/AWSCloudMapDiscoverInstanceAccess"
        - "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
        - "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
        - "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"
        - "arn:aws:iam::aws:policy/AWSCloudMapFullAccess"
EOF
```

Use eksctl to create the new `pixie-demo-ng` node group:

```bash
envsubst < clusterconfig.yaml | eksctl create nodegroup -f -
```

{{% notice info %}}
The creation of the Nodegroup will take about 3 - 5 minutes.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see 3 nodes added to the cluster.

```bash
kubectl get nodes --sort-by=.metadata.creationTimestamp
```

{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-168-4-73.us-west-2.compute.internal     Ready    <none>   6m24s   v1.17.12-eks-7684af
ip-192-168-47-147.us-west-2.compute.internal   Ready    <none>   6m21s   v1.17.12-eks-7684af
ip-192-168-87-132.us-west-2.compute.internal   Ready    <none>   6m19s   v1.17.12-eks-7684af
ip-192-168-53-105.us-west-2.compute.internal   Ready    <none>   117s    v1.17.12-eks-7684af
ip-192-168-88-75.us-west-2.compute.internal    Ready    <none>   108s    v1.17.12-eks-7684af
ip-192-168-26-175.us-west-2.compute.internal   Ready    <none>   103s    v1.17.12-eks-7684af
{{< /output >}}

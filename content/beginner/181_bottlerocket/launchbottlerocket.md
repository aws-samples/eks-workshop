---
title: "Launch Bottlerocket"
date: 2018-08-07T13:34:24-07:00
weight: 20
---

### Add Bottlerocket nodes to an EKS cluster

Create an eksctl deployment file (eksworkshop_bottlerocket.yaml) use in creating your cluster using the following syntax:

```bash
cat << EOF > eksworkshop_bottlerocket.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.17"

availabilityZones: ["${AZS[0]}", "${AZS[1]}", "${AZS[2]}"]

nodeGroups:
  - name: ng-bottlerocket
    instanceType: t2.small
    desiredCapacity: 3
    amiFamily: Bottlerocket
    iam:
       attachPolicyARNs:
          - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
          - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
          - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
          - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
    bottlerocket:
      settings:
        motd: "Hello from eksctl!"

# To enable all of the control plane logs, uncomment below:
# cloudWatch:
#  clusterLogging:
#    enableTypes: ["*"]

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF
```

Next, use the file you created as the input for the eksctl cluster update.

```bash
eksctl create nodegroup -f eksworkshop_bottlerocket.yaml
```

Confirm your nodes
```
kubectl get nodes # if we see our 6 nodes, we know we have deployed bottlerocket correctly
```

{{% notice info %}}
It's possible to have a cluster with both managed and unmanaged nodegroups. Unmanaged nodegroups do not show up in the AWS EKS console but eksctl get nodegroup will list both types of nodegroups.
{{% /notice %}}

#### Congratulations!

You now have a fully working Amazon EKS Cluster with Bottlerocket nodes that is ready to use!


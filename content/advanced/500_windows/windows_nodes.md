---
title: "Windows nodes"
date: 2020-07-27T11:50:00-04:00
draft: false
weight: 520
---

### Enable Windows support

{{% notice warning %}}
This procedure only works for clusters that were created with `eksctl` and assumes that your `eksctl` version is 0.24.0 or later.
{{% /notice %}}

You can check your version with the following command

```bash
eksctl version
```

### Enabling Windows support

The next command will deploy the VPC resource controller and VPC admission controller webhook that are required on Amazon EKS clusters to run Windows workloads.

```bash
eksctl utils \
    install-vpc-controllers \
    --cluster eksworkshop-eksctl \
    --approve
```

### Launching self-managed Windows nodes

Create your node group with the following command

```bash
mkdir ~/environment/windows

cat << EoF > ~/environment/windows/windows_nodes.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

nodeGroups:
  - name: windows-ng
    amiFamily: WindowsServer2019FullContainer
    desiredCapacity: 2
    instanceType: t2.large
EoF

eksctl create nodegroup -f ~/environment/windows/windows_nodes.yaml
```

You can verify that 2 Windows nodes have been added to your cluster by using the command line

```sh
kubectl get nodes
```

{{< output>}}
nodeSelector:
        kubernetes.io/os: windows
        kubernetes.io/arch: amd64
{{< /output>}}

or using the  the [AWS EC2 console](https://console.aws.amazon.com/ec2/v2/home?Instances#Instances:)

![Windows EC2 nodes](/images/windows/windows_nodes.png)

### NodeSelector

After you add Windows support to your cluster, you must specify node selectors on your applications so that the pods land on a node with the appropriate operating system.

For Linux pods, use the following node selector text in your manifests.
{{< output >}}
nodeSelector:
        kubernetes.io/os: linux
        kubernetes.io/arch: amd64
{{< /output>}}

For Windows pods, use the following node selector text in your manifests.

{{< output>}}
nodeSelector:
        kubernetes.io/os: windows
        kubernetes.io/arch: amd64
{{< /output>}}

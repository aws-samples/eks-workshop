---
title: "Windows nodes"
date: 2020-07-27T11:50:00-04:00
draft: false
weight: 320
---

### Enable Windows support

{{% notice warning %}}
This procedure only works for clusters that were created with `eksctl` and assumes that your `eksctl` version is 0.24.0 or later.
{{% /notice %}}

You can check your version with the following command

```bash
eksctl version
```

The next command will deploy the VPC resource controller and VPC [admission controller webhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-are-they) that are required on Amazon EKS clusters to run Windows workloads.

```bash
eksctl utils \
    install-vpc-controllers \
    --cluster eksworkshop-eksctl \
    --approve
```

### Launch self-managed Windows nodes

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
kubectl get nodes \
  -L kubernetes.io/os \
  --sort-by=".status.conditions[?(@.reason == 'KubeletReady' )].lastTransitionTime"
```

Notice the Operating system in the OS column

{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION              OS
ip-192-168-82-113.us-east-2.compute.internal   Ready    <none>   10d     v1.17.7-eks-bffbac   linux
ip-192-168-40-82.us-east-2.compute.internal    Ready    <none>   9d      v1.17.7-eks-bffbac   linux
ip-192-168-23-165.us-east-2.compute.internal   Ready    <none>   9d      v1.17.7-eks-bffbac   linux
ip-192-168-95-199.us-east-2.compute.internal   Ready    <none>   6h33m   v1.17.6-eks-4e7f64   windows
ip-192-168-4-164.us-east-2.compute.internal    Ready    <none>   6h32m   v1.17.6-eks-4e7f64   windows
{{< /output >}}

Or by using the [AWS EC2 console](https://console.aws.amazon.com/ec2/v2/home?Instances#Instances:)

![Windows EC2 nodes](/images/windows/windows_nodes.png)

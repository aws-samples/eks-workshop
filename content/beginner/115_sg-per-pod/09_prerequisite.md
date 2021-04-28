---
title: "Prerequisite"
date: 2021-02-20T16:48:09-05:00
draft: false
weight: 09
---

{{% notice info %}}
Security groups for pods are supported by most Nitro-based Amazon EC2 instance families, including the `m5`, `c5`, `r5`, `p3`, `m6g`, `c6g`, and `r6g` instance families. **The `t3` instance family is not supported** and so we will create a second NodeGroup using one `m5.large` instance.
{{% /notice %}}

```bash
mkdir sg-per-pod

cat << EoF > ${HOME}/environment/sg-per-pod/nodegroup-sec-group.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

managedNodeGroups:
- name: nodegroup-sec-group
  desiredCapacity: 1
  instanceType: m5.large
EoF

eksctl create nodegroup -f ${HOME}/environment/sg-per-pod/nodegroup-sec-group.yaml

 kubectl get nodes \
  --selector beta.kubernetes.io/instance-type=m5.large
```

{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-168-34-45.us-east-2.compute.internal    Ready    <none>   4m57s   v1.17.12-eks-7684af
{{< /output >}}

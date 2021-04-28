---
title: "SecurityGroup Policy"
date: 2020-11-26T16:24:15-05:00
draft: false
weight: 40
tags:
  - beginner
---

### SecurityGroup Policy

A new Custom Resource Definition (CRD) has also been added automatically at the cluster creation. Cluster administrators can specify which security groups to assign to pods through the `SecurityGroupPolicy` CRD. Within a namespace, you can select pods based on pod labels, or based on labels of the service account associated with a pod. For any matching pods, you also define the security group IDs to be applied.

You can verify the CRD is present with this command.

```bash
kubectl get crd securitygrouppolicies.vpcresources.k8s.aws
```

Output
{{< output >}}
securitygrouppolicies.vpcresources.k8s.aws   2020-11-04T17:01:27Z
{{< /output >}}

The webhook watches `SecurityGroupPolicy` custom resources for any changes, and automatically injects matching pods with the extended resource request required for the pod to be scheduled onto a node with available branch network interface capacity. Once the pod is scheduled, the resource controller will create and attach a branch interface to the trunk interface. Upon successful attachment, the controller adds an annotation to the pod object with the branch interface details.

Now let's create our policy.

```bash
cat << EoF > ~/environment/sg-per-pod/sg-policy.yaml
apiVersion: vpcresources.k8s.aws/v1beta1
kind: SecurityGroupPolicy
metadata:
  name: allow-rds-access
spec:
  podSelector:
    matchLabels:
      app: green-pod
  securityGroups:
    groupIds:
      - ${POD_SG}
EoF
```

As we can see, if the pod has the label `app: green-pod`, a security group will be attached to it.

We can finally deploy it in a specific `namespace`.

```bash
kubectl create namespace sg-per-pod

kubectl -n sg-per-pod apply -f ~/environment/sg-per-pod/sg-policy.yaml

kubectl -n sg-per-pod describe securitygrouppolicy
```

Output
{{< output >}}
Name:         allow-rds-access
Namespace:    sg-per-pod
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"vpcresources.k8s.aws/v1beta1","kind":"SecurityGroupPolicy","metadata":{"annotations":{},"name":"allow-rds-access","namespac...
API Version:  vpcresources.k8s.aws/v1beta1
Kind:         SecurityGroupPolicy
Metadata:
  Creation Timestamp:  2020-12-03T04:35:57Z
  Generation:          1
  Resource Version:    9142629
  Self Link:           /apis/vpcresources.k8s.aws/v1beta1/namespaces/sg-per-pod/securitygrouppolicies/allow-rds-access
  UID:                 bf1e329d-816e-4ab0-abe8-934cadabfdd3
Spec:
  Pod Selector:
    Match Labels:
      App:  green-pod
  Security Groups:
    Group Ids:
      sg-0ff967bc903e9639e
Events:  <none>
{{< /output >}}

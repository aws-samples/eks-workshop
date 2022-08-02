---
title: "Launch Bottlerocket"
date: 2021-05-26T00:00:00-03:00
weight: 20
---

### Add Bottlerocket nodes to an EKS cluster

Create an environment variable for the kubernetes version. We will use this in the next step.
```bash
K8S_VERSION=`kubectl version | grep Server | grep -Eo '."v.{0,4}' | sed -n 's/.*:"v//p'`
echo K8S_VERSION: ${K8S_VERSION}
```

Create an eksctl deployment file (eksworkshop_bottlerocket.yaml) use in creating your cluster using the following syntax:

```bash
cat << EOF > eksworkshop_bottlerocket.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "${K8S_VERSION}"

availabilityZones: ["${AZS[0]}", "${AZS[1]}", "${AZS[2]}"]

nodeGroups:
  - name: ng-bottlerocket
    labels: { role: bottlerocket }
    instanceType: t3.small
    desiredCapacity: 1
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


{{% notice info %}}
Launching Bottlerocket nodes will take approximately 10 minutes
{{% /notice %}}

Output: 
{{< output >}}
2021-05-26 16:23:34 [ℹ]  node "ip-192-168-36-124.us-east-2.compute.internal" is ready
{{< /output >}}

Next, run the following command to list all the nodes in the EKS cluster and you should see 4 nodes as follows:

```bash
kubectl get nodes
```

Output:
{{< output >}}
NAME                                           STATUS   ROLES    AGE   VERSION
ip-192-168-21-9.us-east-2.compute.internal     Ready    <none>   8h   v1.17.12-eks-7684af
ip-192-168-36-124.us-east-2.compute.internal   Ready    <none>   72s   v1.17.17
ip-192-168-4-14.us-east-2.compute.internal     Ready    <none>   71s   v1.17.17
ip-192-168-87-9.us-east-2.compute.internal     Ready    <none>   71s   v1.17.17
{{< /output >}}

Your cluster now has 4 worker nodes, 1 of them is using Bottlerocket in an unmanaged nodegroup.

Unmanaged nodegroups do not show up in the AWS EKS console(Configutaion/Compute tab), however the nodes show up in the AWS EKS console(Overview tab). You can also use the "eksctl get nodegroup" command to list both types of nodegroups.
  
```bash
eksctl get nodegroup --cluster=eksworkshop-eksctl
```  

#### Congratulations!

You now have a fully working Amazon EKS Cluster with Bottlerocket nodes that is ready to use!

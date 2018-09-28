---
title: "Preparing the environment"
weight: 20
---
{{% notice info %}}
There are some prerequisites that are necessary for Tigera Secure Cloud Edition to function.
Your Kubernetes cluster must meet the following specifications:

* Exists in a single VPC.
* Has the Kubernetes AWS cloud provider enabled.
* Networking provider is Amazon VPC Networking

{{% /notice %}}
{{% notice info %}}
You will need a host equipped with the following:

* kubectl: configured to access the cluster.
* AWS Command Line Interface (CLI): The following commands are known to work well with AWS CLI 1.15.40
* jq

{{% /notice %}}

If you meet those requirements, then we need to get some environment variables set.  If you used _eksctl_ to install your cluster, then the following commands should set up everything for you.  Just set $CLUSTER_NAME to the name you used when creating the cluster with _eksctl_.
```
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.resourcesVpcConfig.vpcId' --output text)
K8S_NODE_SGS=$(aws ec2 describe-security-groups --filters Name=tag:aws:cloudformation:logical-id,Values=NodeSecurityGroup Name=vpc-id,Values=${VPC_ID} --query "SecurityGroups[0].GroupId" --output text)
CONTROL_PLANE_SG=$(aws ec2 describe-security-groups --filters Name=tag:aws:cloudformation:logical-id,Values=ControlPlaneSecurityGroup Name=vpc-id,Values=${VPC_ID} --query "SecurityGroups[0].GroupId" --output text)
```

If you didn't use _eksctl_ please refer to the instructions in the Tigera Secure CE v1.0.0 download link.

After the environment variables are set, you need to install the _tsctl_ binary on your machine and run it to install Tigera Secure CE on your cluster.

If you have a mac:
```
curl -o tsctl -O https://s3.amazonaws.com/tigera-public/ce/tsctl-darwin-amd64
chmod +x tsctl
```

If you are on a Linux box:
```
curl -o tsctl -O https://s3.amazonaws.com/tigera-public/ce/tsctl-linux-amd64
chmod +x tsctl
```

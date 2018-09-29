---
title: "Preparing the environment"
weight: 20
---
#### There are some prerequisites that are necessary for Tigera Secure Cloud Edition to function.
Your workshop Kubernetes cluster already meets the following specifications:

* Exists in a single VPC.
* Has the Kubernetes AWS cloud provider enabled.
* Networking provider is Amazon VPC Networking

#### Your Cloud9 workspace already meets the software requirements as well:

* kubectl: configured to access the cluster.
* AWS Command Line Interface (CLI): The following commands are known to work well with AWS CLI 1.15.40
* jq

Now let's set some environment variables to use in our commands: If you used
_eksctl_ to install your cluster, then the following commands should set up
everything for you:
```
VPC_ID=$(aws eks describe-cluster --name eksworkshop-eksctl --query 'cluster.resourcesVpcConfig.vpcId' --output text)
K8S_NODE_SGS=$(aws ec2 describe-security-groups --filters Name=tag:aws:cloudformation:logical-id,Values=NodeSecurityGroup Name=vpc-id,Values=${VPC_ID} --query "SecurityGroups[0].GroupId" --output text)
CONTROL_PLANE_SG=$(aws ec2 describe-security-groups --filters Name=tag:aws:cloudformation:logical-id,Values=ControlPlaneSecurityGroup Name=vpc-id,Values=${VPC_ID} --query "SecurityGroups[0].GroupId" --output text)
```

If you didn't use _eksctl_ please refer to the instructions in the Tigera Secure CE v1.0.0 download link.

After the environment variables are set, you need to install the _tsctl_ binary on your machine and run it to install Tigera Secure CE on your cluster.

<!---
If you have a mac:
```
curl -o tsctl -O https://s3.amazonaws.com/tigera-public/ce/tsctl-darwin-amd64
chmod +x tsctl
```

If you are on a Linux box:
--->

```
curl -o tsctl -O https://s3.amazonaws.com/tigera-public/ce/tsctl-linux-amd64
chmod +x tsctl
sudo mv -v tsctl /usr/local/bin/
```

---
title: "Preparing the environment"
weight: 20
---

{{% notice info %}}
If you have setup your kubernetes cluster using the Cloud9 environment and eksctl, as instructed at the start of this workshop, then you can follow the abbreviated instructions here, as much of the work has been done for you.  If not please refer to the instructions you received when you downloaded the _Tigera Secure Cloud Edition 1.0.1_ link.
{{% /notice %}}

{{% notice tip %}}
The instructions below assume that you have followed all of the initial _EKSWorkshop_ setup instructions when creating your cluster.  If you have not, some of the commands or environment settings that we rely on below will not be set correctly.  If you encounter problems, please check your initial setup and/or consult the instructions mentioned above.
{{% /notice %}}

First, you need to install tsctl in your Cloud9 environment.

```
sudo curl --location -o /usr/local/bin/tsctl https://s3.amazonaws.com/tigera-public/ce/v1.0.6/tsctl-linux-amd64
sudo chmod +x /usr/local/bin/tsctl
```

Next, you will need to set some environment variables.  There are commands for some of them, but a few you need to supply.

The $CLUSTER_NAME variable is the same that you used to create the cluster using the 'eksctl' command at the beginning of the workshop.  If you followed the directions, it will be 'eksworkshop-eksctl'

```
CLUSTER_NAME=eksworkshop-eksctl
```

The next thing we need to manually set is your Tigera Secure Cloud Edition $TS_TOKEN.  This can be found by checking your [Zendesk tickets](https://support.tigera.io/hc/en-us/requests).  The Token can be found in your welcome ticket and is a _UUID_, or long string of hex digits.

```
TS_TOKEN=<token UUID>
```

The following commands will set the remainder of the environment variables.

```
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.resourcesVpcConfig.vpcId' --output text)
K8S_NODE_SGS=$(aws ec2 describe-security-groups --filters Name=tag:aws:cloudformation:logical-id,Values=ClusterSharedNodeSecurityGroup Name=vpc-id,Values=${VPC_ID} --query "SecurityGroups[0].GroupId" --output text)
CONTROL_PLANE_SG=$(aws ec2 describe-security-groups --filters Name=tag:aws:cloudformation:logical-id,Values=ControlPlaneSecurityGroup Name=vpc-id,Values=${VPC_ID} --query "SecurityGroups[0].GroupId" --output text)
```

If you have any problems, please make sure that you have setup your Cloud9 environment correctly for the workshop.

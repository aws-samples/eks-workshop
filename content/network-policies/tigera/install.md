---
title: "Installing Tigera Secure Cloud Edition"
weight: 30
---
Now that your environment variables are set, and _tsctl_ is installed, go back to the instructions in the Tigera Secure CE v1.0.0 download link and look for the second step in the **Procedure** section.  It should look something like this:
```
./tsctl install --token <a long hex string goes here> \
            --cluster-name $CLUSTER_NAME \
            --vpc-id $VPC_ID \
            --control-plane-sg $CONTROL_PLANE_SG \
            --node-sgs $K8S_NODE_SGS
```
Copy that text and run it on your machine that has _tsctl_ loaded.  **DO NOT COPY THE TEXT ABOVE** It will not work.  The token is unique to each registration.

{{% notice info %}}
- It may take up to five seconds for pods to gain network connectivity after starting up.
- Due to a kops issue, network policy does not work as expected when trying to reach services via their cluster IP or DNS name. This can result in traffic being allowed when it should be denied or vice versa. For the latest status on this defect and a workaround, refer to issue 4674 in the kops repo.
- Network Load Balancers (NLBs) may lose their ability to balance traffic to pods after installing Tigera Secure CE. To resolve this issue, manually modify the pods’ security group to allow ingress traffic from the original source of the traffic (not the NLB). See the User Guide for more information or contact Tigera support for assistance.
{{% /notice %}}

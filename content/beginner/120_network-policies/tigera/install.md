---
title: "Installing Tigera Secure Cloud Edition"
weight: 30
---
Now that your environment variables are set, and _tsctl_ is installed, we need to install TSCE itself.  To do so, run the following command.  The instructions in the Tigera Secure CE v1.0.1 document that you downloaded earlier are almost exactly the same as what is shown here.  The only difference is that we've changed a variable name from ```$TOKEN``` to ```$TS_TOKEN``` to avoid colliding with other ```$TOKEN``` variables that might be set in your environment.
```
tsctl install --token $TS_TOKEN \
            --kubeconfig ~/.kube/config \
            --cluster-name $CLUSTER_NAME \
            --vpc-id $VPC_ID \
            --control-plane-sg $CONTROL_PLANE_SG \
            --node-sgs $K8S_NODE_SGS
```

Copy that text and run it in your Cloud9 shell.  If all goes well, in a few minutes, you should be running TSCE, which augments Project Calico with a number of interesting capabilities which we will explore next.

### Known Issues

* It may take up to five seconds for pods to gain network connectivity after starting up.

* Network Load Balancers (NLBs) may lose their ability to balance traffic to pods after installing Tigera Secure CE. To resolve this issue, manually modify the pods’ security group to allow ingress traffic from the original source of the traffic (not the NLB). See the User Guide for more information or contact Tigera support for assistance.

---
title: "Ingress"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---

#### Ingress

The final step in exposing the 2048-game service is to deploy an ingress.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-ingress.yaml
```

This will start provisioning an instance of Internet-facing Application Load Balancer. From your AWS Management Console, if you navigate to the EC2 dashboard and the select **Load Balancers** from the menu on the left-pane, you should see the details of the ALB instance similar to the following.
![LoadBalancer Dashboard](/images/fargate/LoadBalancer.png)

From the left-pane, if you select **Target Groups** and look at the registered targets under the **Targets** tab, you will see the IP addresses and ports of the sample app pods listed.
![LoadBalancer Targets](/images/fargate/LoadBalancerTargets.png)

Notice that the pods have been directly registered with the load balancer whereas when we worked with worker nodes in an earlier lab, the IP address of the worker nodes and the NodePort were registered as targets. The latter case is the **Instance Mode** where Ingress traffic starts at the ALB and reaches the Kubernetes worker nodes through each service's NodePort and subsequently reaches the pods through the service’s ClusterIP. While running under Fargate, ALB operates in **IP Mode**, where Ingress traffic starts at the ALB and reaches the Kubernetes pods directly.

Illustration of request routing from an AWS Application Load Balancer to Pods on worker nodes in Instance mode:
![LoadBalancer Instance Mode](/images/fargate/InstanceMode.png)

Illustration of request routing from an AWS Application Load Balancer to Fargate Pods in IP mode:
![LoadBalancer IP Mode](/images/fargate/IPMode.png)

At this point, your deployment is complete and you should be able to reach the 2048-game service from a browser using the DNS name of the ALB. You may get the DNS name of the load balancer either from the AWS Management Console or from the output of the following command.

```bash
export ALB_ADDRESS=$(kubectl get ingress -n 2048-game -o json | jq -r '.items[].status.loadBalancer.ingress[].hostname')

echo "http://${ALB_ADDRESS}"
```

Output should look like this
{{< output >}}
http://3e100955-2048game-2048ingr-6fa0-1056911976.us-east-2.elb.amazonaws.com
{{< /output >}}

![Browser](/images/fargate/Browser.png)

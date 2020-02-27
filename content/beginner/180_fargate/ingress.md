---
title: "Ingress"
date: 2019-04-09T00:00:00-03:00
weight: 15
draft: false
---

#### Ingress 

The final step in exposing the NGINX service is to deploy an ingress.
```
cd ~/environment/fargate
wget https://eksworkshop.com/beginner/180_fargate/fargate.files/nginx-ingress.yaml
```

```
kubectl apply -f nginx-ingress.yaml
```

This will start provisioning an instance of Internet-facing Application Load Balancer. From your AWS Management Console, if you navigate to the EC2 dashboard and the select <b>Load Balancers</b> from the menu on the left-pane, you should see the details of the ALB instance similar to the following.
![LoadBalancer Dashboard](/images/fargate/LoadBalancer.png)

From the left-pane, if you select <b>Target Groups</b> and look at the registered targets under the <b>Targets</b> tab, you will see the IP addresses and ports of the two NGINX pods listed. 
![LoadBalancer Targets](/images/fargate/LoadBalancerTargets.png)

Notice that the pods have been directly registered with the load balancer whereas when we worked with worker nodes in an earlier lab, the IP address of the worker nodes and the NodePort were registered as targets. The latter case is the <b>Instance Mode</b> where Ingress traffic starts at the ALB and reaches the Kubernetes worker nodes through each service's NodePort and subsequently reaches the pods through the service’s ClusterIP. While running under Fargate, ALB operates in <b>IP Mode</b>, where Ingress traffic starts at the ALB and reaches the Kubernetes pods directly. 

Illustration of request routing from an AWS Application Load Balancer to Pods on worker nodes in Instance mode:
![LoadBalancer Instance Mode](/images/fargate/InstanceMode.png)

Illustration of request routing from an AWS Application Load Balancer to Fargate Pods in IP mode:
![LoadBalancer IP Mode](/images/fargate/IPMode.png)


At this point, your deployment is complete and you should be able to reach the NGINX service from a browser using the DNS name of the ALB. You may get the DNS name of the load balancer either from the AWS Management Console or from the output of the following command.
```
kubectl get ingress -n fargate
```
{{< output >}}
NAME            HOSTS   ADDRESS                                                                  PORTS   AGE
nginx-ingress   *       f321c8bc-fargate-nginxingr-f115-1918753093.us-east-1.elb.amazonaws.com   80      40m
{{< /output >}}

![Browser](/images/fargate/Browser.png)

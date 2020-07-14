---
title: "Deploying Pods to Fargate"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---

#### Deploying Pods to Fargate

Deploy the game [2048](https://play2048.co/) as a sample application to verify that the ALB Ingress Controller creates an Application Load Balancer as a result of the Ingress object.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-service.yaml
```

You can check if a Deployment has completed

```bash
kubectl -n 2048-game rollout status deployment 2048-deployment
```

Output:
{{< output >}}
Waiting for deployment "2048-deployment" rollout to finish: 0 of 5 updated replicas are available...
Waiting for deployment "2048-deployment" rollout to finish: 1 of 5 updated replicas are available...
Waiting for deployment "2048-deployment" rollout to finish: 2 of 5 updated replicas are available...
Waiting for deployment "2048-deployment" rollout to finish: 3 of 5 updated replicas are available...
Waiting for deployment "2048-deployment" rollout to finish: 4 of 5 updated replicas are available...
deployment "2048-deployment" successfully rolled out
{{< /output >}}

Next, run the following command to list all the nodes in the EKS cluster and you should see output as follows:

```bash
kubectl get nodes
```

Output:
{{< output >}}
NAME                                                    STATUS   ROLES    AGE     VERSION
fargate-ip-192-168-112-213.us-east-2.compute.internal   Ready    <none>   7m34s   v1.16.8-eks-e16311
fargate-ip-192-168-116-87.us-east-2.compute.internal    Ready    <none>   7m9s    v1.16.8-eks-e16311
fargate-ip-192-168-150-90.us-east-2.compute.internal    Ready    <none>   7m19s   v1.16.8-eks-e16311
fargate-ip-192-168-175-50.us-east-2.compute.internal    Ready    <none>   7m42s   v1.16.8-eks-e16311
fargate-ip-192-168-182-105.us-east-2.compute.internal   Ready    <none>   7m41s   v1.16.8-eks-e16311
ip-192-168-35-11.us-east-2.compute.internal             Ready    <none>   22h     v1.16.8-eks-fd1ea7
ip-192-168-65-174.us-east-2.compute.internal            Ready    <none>   22h     v1.16.8-eks-fd1ea7
ip-192-168-9-6.us-east-2.compute.internal               Ready    <none>   22h     v1.16.8-eks-fd1ea7
{{< /output >}}

If your cluster has any worker nodes, they will be listed with a name starting wit the **ip-** prefix. In addition to the worker nodes, if any, there will now be two additional “fargate” nodes listed. These are merely kubelets from the microVMs in which your sample app pods are running under Fargate, posing as nodes to the EKS Control Plane. This is how the EKS Control Plane stays aware of the Fargate infrastructure under which the pods it orchestrates are running. There will be a “fargate” node added to the cluster for each pod deployed on Fargate.

---
title: "Deploying Pods to Fargate"
date: 2019-04-09T00:00:00-03:00
weight: 13
draft: false
---

### Deploy the sample application

Deploy the game [2048](https://play2048.co/) as a sample application to verify that the AWS Load Balancer Controller creates an Application Load Balancer as a result of the Ingress object.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
```

You can check if the `deployment` has completed

```bash
kubectl -n game-2048 rollout status deployment deployment-2048
```

Output:
{{< output >}}
Waiting for deployment "deployment-2048" rollout to finish: 0 of 5 updated replicas are available...
Waiting for deployment "deployment-2048" rollout to finish: 1 of 5 updated replicas are available...
Waiting for deployment "deployment-2048" rollout to finish: 2 of 5 updated replicas are available...
Waiting for deployment "deployment-2048" rollout to finish: 3 of 5 updated replicas are available...
Waiting for deployment "deployment-2048" rollout to finish: 4 of 5 updated replicas are available...
deployment "deployment-2048" successfully rolled out
{{< /output >}}

Next, run the following command to list all the nodes in the EKS cluster and you should see output as follows:

```bash
kubectl get nodes
```

Output:
{{< output >}}
NAME                                                    STATUS   ROLES    AGE   VERSION
fargate-ip-192-168-110-35.us-east-2.compute.internal    Ready    <none>   47s   v1.17.9-eks-a84824
fargate-ip-192-168-142-4.us-east-2.compute.internal     Ready    <none>   47s   v1.17.9-eks-a84824
fargate-ip-192-168-169-29.us-east-2.compute.internal    Ready    <none>   55s   v1.17.9-eks-a84824
fargate-ip-192-168-174-79.us-east-2.compute.internal    Ready    <none>   39s   v1.17.9-eks-a84824
fargate-ip-192-168-179-197.us-east-2.compute.internal   Ready    <none>   50s   v1.17.9-eks-a84824
ip-192-168-20-197.us-east-2.compute.internal            Ready    <none>   16h   v1.17.11-eks-cfdc40
ip-192-168-33-161.us-east-2.compute.internal            Ready    <none>   16h   v1.17.11-eks-cfdc40
ip-192-168-68-228.us-east-2.compute.internal            Ready    <none>   16h   v1.17.11-eks-cfdc40
{{< /output >}}

If your cluster has any worker nodes, they will be listed with a name starting wit the **ip-** prefix.

In addition to the worker nodes, if any, there will now be five additional **fargate-** nodes listed.
These are merely kubelets from the microVMs in which your sample app pods are running under Fargate, posing as nodes to the EKS Control Plane. This is how the EKS Control Plane stays aware of the Fargate infrastructure under which the pods it orchestrates are running. There will be a “fargate” node added to the cluster for each pod deployed on Fargate.

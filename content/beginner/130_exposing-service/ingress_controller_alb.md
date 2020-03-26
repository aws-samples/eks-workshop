---
title: "Ingress Controller ALB"
date: 2019-04-09T00:00:00-03:00
weight: 14
draft: false
---

### ALB Ingress Controller
Verify the Name of the Cluster with the CLI
```
aws eks list-clusters
```
Output
{{< output >}}
{
        "clusters": [
                "eksworkshop-eksctl"
                    ]
}
{{< /output >}}

Create an IAM OIDC provider and associate it with your cluster
```
eksctl utils associate-iam-oidc-provider --cluster=eksworkshop-eksctl --approve
```
Output
{{< output >}}                                                                               
[ℹ]  eksctl version 0.13.0
[ℹ]  using region us-east-2
[ℹ]  will create IAM Open ID Connect provider for cluster "eksworkshop" in "us-east-2"
[✔]  created IAM Open ID Connect provider for cluster "eksworkshop" in "us-east-2"
{{< /output >}}

Deploy RBAC Roles and RoleBindings needed by the AWS ALB Ingress controller:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
```
Download the AWS ALB Ingress controller YAML into a local file:
```
curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml" > alb-ingress-controller.yaml
```
Edit the AWS ALB Ingress controller YAML to include the clusterName of the Kubernetes (or) Amazon EKS cluster.

Edit the ```–cluster-name``` flag to be the real name of our Kubernetes (or) Amazon EKS cluster in your ```alb-ingress-controller.yaml``` file. In this case, our cluster name was ```eksworkshop-eksctl``` as apparent from the output.

Deploy the AWS ALB Ingress controller YAML:
```
kubectl apply -f alb-ingress-controller.yaml
```
Verify that the deployment was successful and the controller started:
```
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o alb-ingress[a-zA-Z0-9-]+)
```
You should be able to see the following output:
{{< output >}}
-------------------------------------------------------------------------------
AWS ALB Ingress controller
  Release:    v1.1.4
  Build:      git-0db46039
  Repository: https://github.com/kubernetes-sigs/aws-alb-ingress-controller
-------------------------------------------------------------------------------
{{< /output >}}
#### Deploy Sample Application
Now let’s deploy a sample 2048 game into our Kubernetes cluster and use the Ingress resource to expose it to traffic:

Deploy 2048 game resources:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-service.yaml
```

Deploy an Ingress resource for the 2048 game:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-ingress.yaml
```

After few seconds, verify that the Ingress resource is enabled:
```
kubectl get ingress/2048-ingress -n 2048-game
```
You should be able to see the following output:
{{< output >}}
NAME         HOSTS         ADDRESS         PORTS   AGE
2048-ingress   *    DNS-Name-Of-Your-ALB    80     3m
{{< /output >}}
Open a browser. Copy and paste your “DNS-Name-Of-Your-ALB”. You should be to access your newly deployed 2048 game – have fun!

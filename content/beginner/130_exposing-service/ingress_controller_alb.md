---
title: "Ingress Controller"
date: 2019-04-09T00:00:00-03:00
weight: 14
draft: false
---

### Ingress Controllers

In order for the Ingress resource to work, the cluster must have an ingress controller running.

Unlike other types of controllers which run as part of the `kube-controller-manager` binary, Ingress controllers are not started automatically with a cluster.

### AWS Load Balancer Controller

The AWS ALB Ingress Controller has been rebranded to [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller).

AWS Load Balancer Controller is a [controller](https://kubernetes.io/docs/concepts/architecture/controller/) to help manage Elastic Load Balancers for a Kubernetes cluster.

* It satisfies Kubernetes `Ingress` resources by provisioning Application Load Balancers.
* It satisfies Kubernetes `Service` resources by provisioning Network Load Balancers.

In this chapter we will focus on the Application Load Balancer.

[AWS Elastic Load Balancing Application Load Balancer (ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) is a popular AWS service that load balances incoming traffic at the application layer (layer 7) across multiple targets, such as Amazon EC2 instances, in multiple Availability Zones. ALB supports multiple features including host or path based routing, TLS (Transport Layer Security) termination, WebSockets, HTTP/2, AWS WAF (Web Application Firewall) integration, integrated access logs, and health checks.

### Deploy the AWS Load Balancer Controller

We will use **Helm** to install the ALB Ingress Controller.

Check to see if `helm` is installed:

```bash
helm version
```

{{% notice info %}}
If `Helm` is not found, see [installing helm](/beginner/060_helm/helm_intro/install/index.html) for instructions.
{{% /notice %}}

Create IAM OIDC provider

```bash
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster eksworkshop-eksctl \
    --approve
```

{{% notice info %}}
Learn more about [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) in the Amazon EKS documentation.
{{% /notice %}}


Create an IAM policy called **AWSLoadBalancerControllerIAMPolicy**

```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

Create a IAM role and ServiceAccount for the Load Balancer controller, use the ARN from the step above

```bash
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

Install the TargetGroupBinding CRDs

```bash
kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master
```

Deploy the Helm chart from the eks repo

```bash
helm repo add eks https://aws.github.io/eks-charts

helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eksworkshop-eksctl \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.tag="${LBC_VERSION}"
```

### Deploy Sample Application

Now let’s deploy a sample [2048 game](https://gabrielecirulli.github.io/2048/) into our Kubernetes cluster and use the Ingress resource to expose it to traffic:

Deploy 2048 game resources:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
```

After few seconds, verify that the Ingress resource is enabled:

```bash
kubectl get ingress/ingress-2048 -n game-2048
```

You should be able to see the following output

{{< output >}}
NAME           HOSTS   ADDRESS                PORTS   AGE
NAME           HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   *       k8s-game2048-ingress2-8ae3738fd5-251279030.us-east-2.elb.amazonaws.com   80      6m20s
{{< /output >}}

{{% notice warning %}}
It could take 2 or 3 minutes for the ALB to be ready.
{{% /notice %}}

Finally, access the access your newly deployed 2048 game by clicking the URL generated with these commands

```bash
export GAME_2048=$(kubectl get ingress/ingress-2048 -n game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo click this link http://${GAME_2048}
```

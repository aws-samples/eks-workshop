---
title: "Ingress Controller"
date: 2019-04-09T00:00:00-03:00
weight: 14
draft: false
---

### Ingress Controllers

In order for the Ingress resource to work, the cluster must have an ingress controller running.

Unlike other types of controllers which run as part of the `kube-controller-manager` binary, Ingress controllers are not started automatically with a cluster.

### AWS ALB Ingress Controller

[AWS Elastic Load Balancing Application Load Balancer (ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) is a popular AWS service that load balances incoming traffic at the application layer (layer 7) across multiple targets, such as Amazon EC2 instances, in multiple Availability Zones. ALB supports multiple features including host or path based routing, TLS (Transport Layer Security) termination, WebSockets, HTTP/2, AWS WAF (Web Application Firewall) integration, integrated access logs, and health checks.

The open source [AWS ALB Ingress controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller) triggers the creation of an ALB and the necessary supporting AWS resources whenever a Kubernetes user declares an Ingress resource in the cluster. The Ingress resource uses the ALB to route HTTP(S) traffic to different endpoints within the cluster. The AWS ALB Ingress controller works on any Kubernetes cluster including Amazon Elastic Kubernetes Service (Amazon EKS).

### Deploy AWS ALB Ingress controller

First, create an IAM OIDC provider and associate it with your cluster:

```bash
eksctl utils associate-iam-oidc-provider --cluster=eksworkshop-eksctl --approve
```

{{% notice info %}}
Learn more about [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) in the Amazon EKS documentation.
{{% /notice %}}

Next, deploy the relevant RBAC roles and role bindings as required by the AWS ALB Ingress controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/rbac-role.yaml
```

Next, create an IAM policy named `ALBIngressControllerIAMPolicy` to allow the ALB Ingress controller to make AWS API calls on your behalf and save the `Policy.Arn` into a new variable called PolicyARN:

```bash
#create the policy
aws iam create-policy \
  --policy-name ALBIngressControllerIAMPolicy \
  --policy-document https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/iam-policy.json

#get the policy ARN
export PolicyARN=$(aws iam list-policies --query 'Policies[?PolicyName==`ALBIngressControllerIAMPolicy`].Arn' --output text)
```

Next, create a Kubernetes service account and an IAM role (for the pod running the AWS ALB Ingress controller):

```bash
eksctl create iamserviceaccount \
        --cluster=eksworkshop-eksctl \
        --namespace=kube-system \
        --name=alb-ingress-controller \
        --attach-policy-arn=$PolicyARN \
        --override-existing-serviceaccounts \
        --approve
```

Then, deploy AWS ALB Ingress controller

```bash
# We dynamically replace the cluster-name by the name of our cluster before applying the YAML file
curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/alb-ingress-controller.yaml" \
    | sed 's/# - --cluster-name=devCluster/- --cluster-name=eksworkshop-eksctl/g' \
    | kubectl apply -f -
```

Verify that the deployment was successful and the controller started:

```bash
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o alb-ingress[a-zA-Z0-9-]+)
```

Finally, verify that the deployment was successful and the controller started:

{{< output >}}
-------------------------------------------------------------------------------
AWS ALB Ingress controller
  Release:    v1.1.8
  Build:      git-ec387ad1
  Repository: https://github.com/kubernetes-sigs/aws-alb-ingress-controller.git
-------------------------------------------------------------------------------
{{< /output >}}

#### Deploy Sample Application

Now let’s deploy a sample [2048 game](https://gabrielecirulli.github.io/2048/) into our Kubernetes cluster and use the Ingress resource to expose it to traffic:

Deploy 2048 game resources:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-service.yaml
```

Deploy an Ingress resource for the 2048 game:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/${ALB_INGRESS_VERSION}/docs/examples/2048/2048-ingress.yaml
```

After few seconds, verify that the Ingress resource is enabled:

```bash
kubectl get ingress/2048-ingress -n 2048-game
```

You should be able to see the following output:
{{< output >}}
NAME           HOSTS   ADDRESS                PORTS   AGE
2048-ingress   *       DNS-Name-Of-Your-ALB   80      3m
{{< /output >}}

{{% notice warning %}}
It could take 2 or 3 minutes for the ALB to be ready.
{{% /notice %}}

Open a browser and copy-paste your `DNS-Name-Of-Your-ALB` and you should be able to access your newly deployed 2048 game – have fun!

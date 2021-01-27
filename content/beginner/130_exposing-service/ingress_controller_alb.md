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

{{% notice note %}}
The AWS ALB Ingress Controller has been rebranded to [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller).
{{% /notice %}}

AWS Load Balancer Controller is a [controller](https://kubernetes.io/docs/concepts/architecture/controller/) to help manage Elastic Load Balancers for a Kubernetes cluster.

* It satisfies Kubernetes `Ingress` resources by provisioning [Application Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html).
* It satisfies Kubernetes `Service` resources by provisioning [Network Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html).

In this chapter we will focus on the Application Load Balancer.

AWS Elastic Load Balancing Application Load Balancer (ALB) is a popular AWS service that load balances incoming traffic at the application layer (layer 7) across multiple targets, such as Amazon EC2 instances, in multiple Availability Zones.

ALB supports multiple features including:

* host or path based routing
* TLS (Transport Layer Security) termination, WebSockets
* HTTP/2
* AWS WAF (Web Application Firewall) integration
* integrated access logs, and health checks

### Deploy the AWS Load Balancer Controller

#### Prerequisites

We will verify if the AWS Load Balancer Controller version has been set

```bash
if [ ! -x ${LBC_VERSION} ]
  then
    tput setaf 2; echo '${LBC_VERSION} has been set.'
  else
    tput setaf 1;echo '${LBC_VERSION} has NOT been set.'
fi
```

{{% notice info %}}
If the result is <span style="color:red">${LBC_VERSION} has NOT been set.</span>, click [here](/020_prerequisites/k8stools/#set-the-aws-load-balancer-controller-version) for the instructions.
{{% /notice %}}

We will use **Helm** to install the ALB Ingress Controller.

Check to see if `helm` is installed:

```bash
helm version --short
```

{{% notice info %}}
If `Helm` is not found, click [installing Helm CLI](/beginner/060_helm/helm_intro/install/index.html) for instructions.
{{% /notice %}}

#### Create IAM OIDC provider

```bash
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster eksworkshop-eksctl \
    --approve
```

{{% notice note %}}
Learn more about [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) in the Amazon EKS documentation.
{{% /notice %}}

#### Create an IAM policy called

Create a policy called **AWSLoadBalancerControllerIAMPolicy**

```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

#### Create a IAM role and ServiceAccount

```bash
eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

#### Install the TargetGroupBinding CRDs

```bash
kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master

kubectl get crd
```

#### Deploy the Helm chart

The helm chart will deploy from the eks repo

```bash
helm repo add eks https://aws.github.io/eks-charts

helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eksworkshop-eksctl \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.tag="${LBC_VERSION}"

kubectl -n kube-system rollout status deployment aws-load-balancer-controller
```

### Deploy Sample Application

Now let’s deploy a sample [2048 game](https://gabrielecirulli.github.io/2048/) into our Kubernetes cluster and use the Ingress resource to expose it to traffic:

Deploy 2048 game resources:

```bash
curl -s https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml \
    | sed 's=alb.ingress.kubernetes.io/target-type: ip=alb.ingress.kubernetes.io/target-type: instance=g' \
    | kubectl apply -f -
```

After few seconds, verify that the Ingress resource is enabled:

```bash
kubectl get ingress/ingress-2048 -n game-2048
```

You should be able to see the following output

{{< output >}}
NAME           HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   *       k8s-game2048-ingress2-8ae3738fd5-251279030.us-east-2.elb.amazonaws.com   80      6m20s
{{< /output >}}

You can find more information on the ingress with this command:

```bash
export GAME_INGRESS_NAME=$(kubectl -n game-2048 get targetgroupbindings -o jsonpath='{.items[].metadata.name}')

kubectl -n game-2048 get targetgroupbindings ${GAME_INGRESS_NAME} -o yaml
```

output

{{< output >}}
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  creationTimestamp: "2020-10-24T20:16:37Z"
  finalizers:
  - elbv2.k8s.aws/resources
  generation: 1
  labels:
    ingress.k8s.aws/stack-name: ingress-2048
    ingress.k8s.aws/stack-namespace: game-2048
  name: k8s-game2048-service2-0e5fd48cc4
  namespace: game-2048
  resourceVersion: "292608"
  selfLink: /apis/elbv2.k8s.aws/v1beta1/namespaces/game-2048/targetgroupbindings/k8s-game2048-service2-0e5fd48cc4
  uid: a1e3567e-429d-4f3c-b1fc-1131775cb74b
spec:
  networking:
    ingress:
    - from:
      - securityGroup:
          groupID: sg-0f2bf9481b203d45a
      ports:
      - protocol: TCP
  serviceRef:
    name: service-2048
    port: 80
  targetGroupARN: arn:aws:elasticloadbalancing:us-east-2:197520326489:targetgroup/k8s-game2048-service2-0e5fd48cc4/4e0de699a21473e2
  targetType: instance
status:
  observedGeneration: 1
{{< /output >}}

Finally, you access your newly deployed 2048 game by clicking the URL generated with these commands

{{% notice warning %}}
It could take 2 or 3 minutes for the ALB to be ready.
{{% /notice %}}

```bash
export GAME_2048=$(kubectl get ingress/ingress-2048 -n game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo http://${GAME_2048}
```

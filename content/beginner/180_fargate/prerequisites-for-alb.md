---
title: "Setup Prerequisites for ALB"
date: 2019-04-09T00:00:00-03:00
weight: 13
draft: false
---

#### Create an OIDC Provider

First, we will have to set up an OIDC provider with the cluster and create the IAM policy to be used by the ALB Ingress Controller.  This step is required to give IAM permissions to a Fargate pod running in the cluster using the [IAM for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) feature.

```bash
eksctl utils associate-iam-oidc-provider \
--cluster eksworkshop-eksctl \
--region=$AWS_REGION \
--approve
```

#### Create an IAM Policy for ALB Ingress

The next step is to create the IAM policy that will be used by the ALB Ingress Controller deployment. This policy will be later associated to the Kubernetes Service Account and will allow the ALB Ingress Controller pods to create and manage the ALB’s resources in your AWS account for you.

```bash
cd ~/environment/fargate
wget https://eksworkshop.com/beginner/180_fargate/fargate.files/alb-ingress-iam-policy.json
```

```bash
aws iam create-policy \
  --policy-name ALBIngressControllerIAMPolicy \
  --policy-document file://alb-ingress-iam-policy.json
```

You will see the policy information output as shown below. Note down the ARN of the policy that you just created.

Output:
{{< output >}}
{
    "Policy": {
        "PolicyName": "ALBIngressControllerIAMPolicy",
        "PolicyId": "ANPA5UPUHMRP4ODFXYB5W",
        "Arn": "arn:aws:iam::937351930975:policy/ALBIngressControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2020-02-21T22:37:49Z",
        "UpdateDate": "2020-02-21T22:37:49Z"
    }
}
{{< /output >}}

#### Creating Service Account

We  need the policy's [Amazon Resource Name (ARN)](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) to create the Service Account with the proper permissions.

```bash
export FARGATE_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`ALBIngressControllerIAMPolicy`].Arn' --output text)
```

Next, create a Kubernetes Service Account by executing the following command

```bash
eksctl create iamserviceaccount \
  --name alb-ingress-controller \
  --namespace 2048-game \
  --cluster eksworkshop-eksctl \
  --attach-policy-arn ${FARGATE_POLICY_ARN} \
  --approve \
  --override-existing-serviceaccounts
```

The above command deploys a CloudFormation template that creates an IAM role and attaches the IAM policy to it. The IAM role gets associated with a Kubernetes Service Account. You can see details of the service account created with the following command.

{{% notice info %}}
For more information on IAM Roles for Service Accounts [follow this link](/beginner/110_irsa/).
{{% /notice %}}

```bash
kubectl get sa alb-ingress-controller -n 2048-game -o yaml
```

Output:

{{< output >}}
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::197520326489:role/eksctl-eksworkshop-eksctl-addon-iamserviceac-Role1-KI23J8XS8Y3H
  creationTimestamp: "2020-03-07T22:40:34Z"
  name: alb-ingress-controller
  namespace: 2048-game
  resourceVersion: "692979"
  selfLink: /api/v1/namespaces/2048-game/serviceaccounts/alb-ingress-controller
  uid: a85f5574-60c4-11ea-81a5-02920c051794
secrets:
- name: alb-ingress-controller-token-2rbtd
{{< /output >}}

#### Create RBAC Role

Next, you will have to create a Cluster Role and Cluster Role Binding that grant requisite permissions to the Service Account you just created.

```bash
cd ~/environment/fargate
wget https://eksworkshop.com/beginner/180_fargate/fargate.files/rbac-role.yaml
```

```bash
kubectl apply -f rbac-role.yaml
```

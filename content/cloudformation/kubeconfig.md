---
title: "Configure Kubectl"
date: 2018-08-07T10:09:31-07:00
weight: 50
draft: false
---
[Kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) is a command line interface for running commands against Kubernetes clusters.

https://kubernetes.io/docs/reference/kubectl/cheatsheet/
Our kubeconfig file will need to know specific info about our EKS cluster. The update-kubeconfig command greatly simplifies the kubeconfig creation process.

#### Confirm your AWS CLI version

```bash
aws --version
```

{{% notice info %}}
To use the AWS CLI with Amazon EKS, you must have at least version `1.16.18` of the AWS CLI installed.
{{% /notice %}}
**Is your AWS CLI out of date?**
{{%expand "Expand here to see how to upgrade" %}}

```bash
pip install awscli --upgrade --user
```

{{% /expand%}}

#### Challenge:
**Build the kubeconfig file**

Explore the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html) for information on how configure the kubeconfig file.

{{%expand "Expand here to see the solution" %}}

```bash
aws eks update-kubeconfig --name eksworkshop
```

{{% /expand %}}

Let’s confirm that your KubeConfig is available:

```bash
kubectl config view
```

Let’s confirm that you can communicate with the Kubernetes API for your EKS cluster

```bash
kubectl get svc
```
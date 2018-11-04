---
title: "Configure Kubectl"
date: 2018-08-07T10:09:31-07:00
weight: 50
draft: false
---
[Kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) is a command line interface for running commands against Kubernetes clusters. 

https://kubernetes.io/docs/reference/kubectl/cheatsheet/
Our kubeconfig file will need to know specific info about our EKS cluster. The update-kubeconfig command greatly simplifies the kubeconfig creation process. 

To use the AWS CLI with Amazon EKS, you must have at least version `1.16.18` of the AWS CLI installed. 

#### Confirm your AWS CLI version 
```
aws --version
```
{{%expand "CLI out of date?" %}}
```
pip install awscli --upgrade --user
```
{{% /expand%}}

#### Build the kubeconfig file
Explore the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide) for information on how configure the kubeconfig file.

{{%expand "Need a hint?"%}}
https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
{{%/expand%}}


{{%expand "Still Stuck?" %}}
```
aws eks update-kubeconfig --name eksworkshop
```
{{% /expand%}}


Let’s confirm that your KubeConfig is available:
```
kubectl config view
```

Let’s confirm that you can communicate with the Kubernetes API for your EKS cluster
```
kubectl get svc
```

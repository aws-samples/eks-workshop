---
title: "Install WordPress"
chapter: false
weight: 2
---

![alt text](/images/ekscwci/wordpresslogo.png "Wordpress Logo")

{{% notice note %}}
We'll be using the [bitnami charts repository](https://github.com/bitnami/charts) to install WordPress to our EKS cluster.
{{% /notice %}}

In your Cloud9 Workspace terminal you just need to run the following commands to deploy WordPress and its database.

```bash
# Create a namespace wordpress
kubectl create namespace wordpress-cwi

# Add the bitnami Helm Charts Repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Deploy WordPress in its own namespace
helm -n wordpress-cwi install understood-zebu bitnami/wordpress
```

This chart will create:

* Two [persistent volumes claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)..
* Multiple [secrets](https://kubernetes.io/docs/concepts/configuration/secret/).
* One [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) for MariaDB.
* One [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) for Wordpress.

You can follow the status of the deployment with this command

```bash
kubectl -n wordpress-cwi rollout status deployment understood-zebu-wordpress
```

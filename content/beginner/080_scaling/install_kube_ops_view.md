---
title: "Install Kube-ops-view"
date: 2020-10-01T08:30:11-07:00
weight: 5
---

Before starting to learn about the various auto-scaling options for your EKS cluster we are going to install [Kube-ops-view](https://github.com/hjacobs/kube-ops-view) from **[Henning Jacobs](https://github.com/hjacobs)**.\
Kube-ops-view provides a common operational picture for a Kubernetes cluster that helps with understanding our cluster setup in a visual way.

{{% notice note %}}
We will deploy kube-ops-view using `Helm` configured in a previous [module](/beginner/060_helm/helm_intro/install/index.html)
{{% /notice %}}

First we will add helm repository that contains the chart kube-ops-view and update the repository

```
helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo update
```


The following line installs kube-ops-view.

```
helm install kube-ops-view k8s-at-home/kube-ops-view
```

The execution above installs kube-ops-view. 
A successful execution of the command will display the set of resources created and will prompt some advice asking you to use `kubectl proxy` and a local URL for the service. 

Use the following command from the above prompt to set the POD_NAME variable

```
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=kube-ops-view,app.kubernetes.io/instance=kube-ops-view" -o jsonpath="{.items[0].metadata.name}")
```

To check the chart was installed successfully:

```
helm list
```

should display : 
```
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kube-ops-view   1               Sun Sep 22 11:47:31 2019        DEPLOYED        kube-ops-view-1.1.4     20.4.0            default  
```

Next, run the kubectl port-forward to access the deployment in your local machine

```
kubectl port-forward $POD_NAME 8080:8080 > /dev/null &
```

With this we can explore kube-ops-view output by accessing the following url. 

```
http://localhost:8080/#
```

Opening the URL in your browser will provide the current state of our cluster.

{{% notice note %}}
You may need to refresh the page and clean your browser cache. 
{{% /notice %}}

![kube-ops-view](/images/kube_ops_view/kube-ops-view.png)

As this workshop moves along and you perform scale up and down actions, you can check the effects and changes in the cluster using kube-ops-view. Check out the different components and see how they map to the concepts that we have already covered during this workshop.

{{% notice tip %}}
Spend some time checking the state and properties of your EKS cluster. 
{{% /notice %}}

![kube-ops-view](/images/kube_ops_view/kube-ops-view-legend.png)

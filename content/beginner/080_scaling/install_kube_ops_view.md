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

The following line updates the stable helm repository and then installs kube-ops-view using a LoadBalancer Service type and creating a RBAC (Resource Base Access Control) entry for the read-only service account to read nodes and pods information from the cluster.

```
helm install kube-ops-view \
stable/kube-ops-view \
--set service.type=LoadBalancer \
--set rbac.create=True
```

The execution above installs kube-ops-view  exposing it through a Service using the LoadBalancer type.
A successful execution of the command will display the set of resources created and will prompt some advice asking you to use `kubectl proxy` and a local URL for the service. Given we are using the type LoadBalancer for our service, we can disregard this; Instead we will point our browser to the external load balancer.

{{% notice warning %}}
Monitoring and visualization shouldn't be typically be exposed publicly unless the service is properly secured and provide methods for authentication and authorization. You can still deploy kube-ops-view using a Service of type **ClusterIP** by removing the  `--set service.type=LoadBalancer` section and using `kubectl proxy`. Kube-ops-view does also [support Oauth 2](https://github.com/hjacobs/kube-ops-view#configuration) 
{{% /notice %}}

To check the chart was installed successfully:

```
helm list
```

should display : 
```
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kube-ops-view   1               Sun Sep 22 11:47:31 2019        DEPLOYED        kube-ops-view-1.1.0     0.11            default  
```

With this we can explore kube-ops-view output by checking the details about the newly service created. 

```
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```

This will display a line similar to `Kube-ops-view URL = http://<URL_PREFIX_ELB>.amazonaws.com`
Opening the URL in your browser will provide the current state of our cluster.

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see kub-ops-view. 
{{% /notice %}}

![kube-ops-view](/images/kube_ops_view/kube-ops-view.png)

As this workshop moves along and you perform scale up and down actions, you can check the effects and changes in the cluster using kube-ops-view. Check out the different components and see how they map to the concepts that we have already covered during this workshop.

{{% notice tip %}}
Spend some time checking the state and properties of your EKS cluster. 
{{% /notice %}}

![kube-ops-view](/images/kube_ops_view/kube-ops-view-legend.png)

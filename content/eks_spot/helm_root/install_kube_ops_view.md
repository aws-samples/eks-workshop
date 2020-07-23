---
title: "Install Kube-ops-view"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

Now that we have helm installed, we are ready to use the stable helm catalog and install tools 
that will help with understanding our cluster setup in a visual way. The first of those tools that we are going to install is [Kube-ops-view](https://github.com/hjacobs/kube-ops-view) from **[Henning Jacobs](https://github.com/hjacobs)**.

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

![kube-ops-view](/images/using_ec2_spot_instances_with_eks/helm/kube-ops-view.png)

As this workshop moves along and you create Spot workers, and perform scale up and down actions, you can check the effects and changes in the cluster using kube-ops-view. Check out the different components and see how they map to the concepts that we have already covered during this workshop.

{{% notice tip %}}
Spend some time checking the state and properties of your EKS cluster. 
{{% /notice %}}

![kube-ops-view](/images/using_ec2_spot_instances_with_eks/helm/kube-ops-view-legend.png)

<!--  

# I'm commenting this section temporarily The ClusterRole associated with
# the chart does not provide all the permissions for kube-report-ops
# to work well and instead we are getting an error at the moment on EKS 1.16
# this will require either a change in the kube-report-ops or changes to modify
# The clusterrole once the helm chart is installed; I'll contribute this to the
# upstream project and then get this section enabled back again.

### Exercise
 
{{% notice info %}}
In this exercise we will install and explore another great tool, **[kube-resource-report](https://github.com/hjacobs/kube-resource-report)** by [Henning Jacob](https://github.com/hjacobs). Kube-resource-report generates a utilization report and associates a cost to namespaces, applications and pods. Kube-resource-report does also take into consideration the Spot savings. It uses the [describe-spot-price-history](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSpotPriceHistory.html) average value of the reported in the last three days to provide an estimate for the cost of EC2 Spot nodes.  
{{% /notice %}}

 * Now that we have a way to visualize our cluster with kube-ops-view, how about visualizing the estimated cost used by our cluster  namespaces, applications and pods? Follow the instructions described at **[kube-resource-report](https://github.com/hjacobs/kube-resource-report)** github repository and figure out how to deploy the helm chart with the right required parameters. (links to hints: [1](https://helm.sh/docs/chart_template_guide/values_files/), [2](https://github.com/hjacobs/kube-resource-report/blob/master/chart/kube-resource-report/values.yaml), [3](https://github.com/hjacobs/kube-resource-report/blob/master/chart/kube-resource-report/templates/deployment.yaml), [4](https://github.com/hjacobs/kube-resource-report/blob/master/chart/kube-resource-report/templates/service.yaml))


{{%expand "Show me the solution" %}}
Execute the following command in your Cloud9 terminal
```
git clone https://github.com/hjacobs/kube-resource-report
helm install kube-resource-report \
--set service.type=LoadBalancer \
--set service.port=80 \
--set container.port=8080 \
--set rbac.create=true \
--set nodeSelector.intent=control-apps \
kube-resource-report/unsupported/chart/kube-resource-report
```

This will install the chart with the right setup, ports and the identification of the label *aws.amazon.com/spot*, that when is defined on a resource, will be used to extract EC2 Spot historic prices associated with the resource. Note that during the rest of the workshop we will still use the `lifecycle` label to identify Spot instances, and only use `aws.amazon.com/spot` to showcase the integration with kube-resource-report. 

Once installed, you should be able to get the Service/Loadbalancer URL using:
```
kubectl get svc kube-resource-report | tail -n 1 | awk '{ print "Kube-resource-report URL = http://"$4 }'
```
{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in four minutes or so you should see kube-resource-report. 
{{% /notice %}}

Kube-resource-reports will keep track in time of the cluster. Further more, it identifies EC2 Spot nodes and uses [AWS Historic Spot price API](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSpotPriceHistory.html) to calculates the current price of the EC2 Spot instances and attribute the correct cost.

![kube-resource-reports](/images/using_ec2_spot_instances_with_eks/helm/kube-resource-reports.png)

{{% /expand %}}

The result of this exercise should show kube-resource-report estimated cost of your cluster as well as the utilization of different components.

-->
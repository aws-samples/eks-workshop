---
title: "Rightsizing Applications"
date: 2019-04-09T00:00:00-03:00
weight: 16
draft: false
---

### Right Size Pod Requirements For Optimal Resource Allocation
One of the challenging tasks of managing containerized clusters is estimating your Pods’ resource requirements in terms of vCPU and memory. Even if development teams manage to achieve an accurate estimate of their application’s resource consumption, chances are that these measurements will vary in a production environment.

Ocean’s Right Sizing feature compares the CPU & Memory requests of your Pods to their actual consumption in production. After analyzing the difference, Ocean provides resizing recommendations to improve the resource configuration of the Deployments.

<img src="/images/ocean/rightsizing.png" alt="Right Sizing" width="700"/>

Applying accurate resource requests and limits to Deployments can help prevent over-provisioning of extra resources which leads to underutilization and higher cluster costs, or under-provisioning of fewer resources than required, which may lead to various errors such as OOM events.

The Right Sizing feature requires having the [Metric Server](https://github.com/kubernetes-incubator/metrics-server#deployment) installed in your EKS cluster. 

{{% notice info %}}
Once the Metric Server is installed, Ocean requires up to 4 days metric collection, in order to dispaly suggestions.
{{% /notice %}}

Once active, top reccomendations can be found aggregated under the Cluster's "Right Sizing" tab, as seen in the screenshot above, beneath the cluster-wide CPU and Memory graphs which show the cluster's total requested resources vs Ocean's recommended values.

Viewing a particular Deployment will display collected metrics compared to it's resource requests and limits, as well as any resizing recommendations.

#### Example 1
Below you can see a recommendation that suggests reducing the requested values for both CPU and Memory of a certain Deployment. Considering a large number of pods, applying such a recommendation can significantly reduce overprovisioning.
<img src="/images/ocean/rightsizing_1.png" alt="Right Sizing Example 1" width="700"/>
The recommendation can be easily applied via kubectl:

`kubectl set resources DeploymentName --requests=cpu=3575,memory=3001`

#### Example 2
Below you can see a recommendation that suggests increasing the requested values for CPU, but reducing Memory values. Overall, applying recommendations leads to improved cluster performance.
<img src="/images/ocean/rightsizing_2.png" alt="Right Sizing Example 2" width="700"/>

You can also use the Right Sizing feature via [API](https://api.spotinst.com/spotinst-api/ocean/ocean-cloud-api/ocean-for-aws/get-right-sizing-recommendations/).


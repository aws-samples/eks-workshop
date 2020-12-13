---
title: "Navigating the Kubernetes cluster on EKS with kubenav"
date: 2020-09-19T00:19:00+05:30
weight: 10
---

Let's look at some of the images as we navigate our cluster with `kubenav`.

This is the landing page when we enter, `http://localhost:14122`.

![0-landing](/images/begin-kubenav/0-landing-page.png)

Scroll to almost the end on the left hand side navigation bar to locate the section **Cluster** and click on **Nodes**. This will show the nodes of our cluster.

![1-nodes](/images/begin-kubenav/1-cluster-nodes.png)

Click on one of the nodes to see more details about the node. You should see the output similar to the one seen below.

![2-node](/images/begin-kubenav/2-node-detail.png)

To locate our `kubenav` deployment, we have to first switch to the `kubenav` namespace. To do this, first, scroll up half-way on the left hand side navigation bar to locate **Discovery and Load Balancing** and click on **Services**. Then, on the top right corner, click on the **Settings** icon to locate the `kubenav` namespace and click on it. This will show the `kubenav` `Service`.

![3-service-list](/images/begin-kubenav/3-service-list.png)

Click on the `kubenav` `Service` for details. The output should look like this.

![4-service-detail](/images/begin-kubenav/4-service-detail.png)

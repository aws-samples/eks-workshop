---
title: "Create Network Policies Using Calico"
weight: 10
---

In this Chapter, we will create some network policies using [Calico](https://www.projectcalico.org/) and see the rules in action.

Network policies allow you to define rules that determine what type of traffic is allowed to flow between different services. Using network policies you can also define rules to restrict traffic. They are a means to improve your cluster's security.

For example, you can only allow traffic from frontend to backend in your application.

Network policies also help in isolating traffic within namespaces. For instance, if you have separate namespaces for development and production, you can prevent traffic flow between them by restrict pod to pod communication within the same namespace.


![calico](/images/Project-Calico-logo-1000px.png)

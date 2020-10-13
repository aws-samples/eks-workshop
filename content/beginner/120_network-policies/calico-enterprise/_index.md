---
title: "Calico Enterprise Usecases"
weight: 20
date: 2020-08-13T02:28:35-05:00
---

### CALICO ENTERPRISE USE CASES

In this module, we will use Tigera’s [Calico Enterprise](https://www.tigera.io/tigera-products/calico-enterprise) to implement the following 3 Amazon EKS use cases:

### 1) Implement Egress Access Controls

   Establishing service to service connectivity within your Amazon EKS cluster is easy. But how do you enable some of your workloads to securely connect to services like Amazon RDS, ElasticCache, etc. that are external to the cluster.

   With Calico Enterprise, you can author DNS Policies that implement fine-grained access controls between a workload and the external services it needs to connect to.

### 2) Troubleshoot Microservice Connectivity

   Troubleshooting microservice connectivity issues can be incredibly difficult due to the dynamic nature of container orchestration in Amazon EKS. Connectivity issues can be related to network performance, but often are the result of your Network Policies not being defined properly.

   With Calico Enterprise, you can explore a visual representation of all your microservices communicating with each other, and filter by connections that were accepted and denied. You can further drill into an individual denied connection to see which Network Policy evaluated and denied the connection, and then fix the policy to resolve the connectivity issue.

### 3) Implement Enterprise Security Controls

   Many applications have compliance requirements such as workload isolation, ensuring dev cannot talk to prod or implementing network zones (e.g. DMZ can communicate with the public internet but not your backend databases). While you can implement these rules using open-source Project Calico, there are a few limitations:
  - It is possible for other users to inadvertently override or intentionally tamper with your security controls, and very difficult to detect when that happens.
  - Proof that the policies have been enforced now and in the past is not possible
 
With Calico Enterprise, you can implement Security Controls at a higher precedent policy tier that cannot be overridden by other users. You will also learn how to provide audit reports that demonstrate compliance now and historically, as well as audit (or alert on) changes to policies.



---
title: "Introduction to Open Policy Agent"
weight: 10
draft: false
---

### Open Policy Agent

OPA decouples policy decision-making from policy enforcement. When your software needs to make policy decisions it queries OPA and supplies structured data (e.g., JSON) as input. OPA accepts arbitrary structured data as input.

OPA generates policy decisions by evaluating the query input and against policies and data. OPA and Rego are domain-agnostic so you can describe almost any kind of invariant in your policies. For example:

![Image](/images/opa/opa-service.png)

- Which users can access which resources.
- Which subnets egress traffic is allowed to.
- Which clusters a workload must be deployed to.
- Which registries binaries can be downloaded from.
- Which OS capabilities a container can execute with.
- Which times of day the system can be accessed at.
- Which subnets egress traffic is allowed to.
- Which clusters a workload must be deployed to.
- Which registries binaries can be downloaded from.
- Which OS capabilities a container can execute with.
- Which times of day the system can be accessed at.

Policy decisions are not limited to simple yes/no or allow/deny answers. Like query inputs, your policies can generate arbitrary structured data as output.
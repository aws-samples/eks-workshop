---
title: "Lab 3: Implementing Existing Security Controls in Kubernetes"
weight: 30
---

### Getting Started 

Before you go any further, please remember to type 'lab3 set_up' in the terminal to set up the environment for this lab.

### Introduction

In this lab, you will learn how Calico Enterprise makes it easy for security and compliance teams to extend existing enterprise controls to Kubernetes. The dynamic nature of workloads within a cluster presents a number of challenges for security and compliance practitioners. Calico Enterprise addresses these challenges with a tool set that extends Kubernetes itself and understands the declarative metadata within your cluster.

You will learn the following:

   - How to use declarative and label-based Calico Network Policies to enforce zone-based controls and security requirements
   - How to use Policy Tiers as way to enforce higher precedent security and compliance policies that cannot be circumvented by application and development teams
   - How to define Compliance Reports that leverage Kubernetes constructs and can be run on a continuous basis in lock step with your CI/CD pipeline
   - How to use audit logs to monitor and alert on changes to network policies with git-friendly diffs

### Setup - Source : [Implementing Existing Security Controls in Kubernetes](https://info.tigera.io/rs/805-GFH-732/images/Calico-Enterprise-Lab03.pdf?mkt_tok=eyJpIjoiTVRjek1EWTNNemRtTkRVdyIsInQiOiJoY3l5aUE1MEFiRk1Ia2NLSDN6b0JWRU5HMlhORUswTm14MldkQ1owbkl4ZkN6Vm5LRmdXOGZ1R094MG5KOFVYXC9GcmdOUmY4YzdjbUo1dGdaNUFMQ1E9PSJ9)


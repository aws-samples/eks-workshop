---
title: "Prerequisites"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

### At an AWS Event
If you are running this chapter at an AWS Event, the prerequisites have already been met, and you can now [move forward to the next chapter.](../clone_repo)

### On Your Own
If you are running this chapter on your own, your environment must meet the following requirements:

#### AWS CLI
The minimal supported version of the AWS CLI supported is 1.16.133.

#### The jq utility
The jq utility is required by some of this module's scripts.  Make sure that you have it installed on the machine from which you run the tutorial steps.

#### Kubernetes and kubectl
The minimal Kubernetes and kubectl versions supported are 1.11. You need a Kubernetes cluster deployed on Amazon Elastic Compute Cloud (Amazon EC2) or on an Amazon EKS cluster. Although the steps in this tutorial demonstrate using App Mesh on Amazon EKS, the instructions also work on upstream k8s running on Amazon EC2.

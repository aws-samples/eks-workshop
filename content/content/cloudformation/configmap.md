---
title: "Create the Worker ConfigMap"
date: 2018-08-07T12:00:40-07:00
weight: 70
draft: false
---

We have supplied a an example configmap that we can use for our EKS workers. We need to substitute our instance role ARN into the template:

View the template:
####TODO: Place file and replace with link.

Find the RoleArn and replace `<ARN of instance role (not instance profile)>` with the actual Role ARN from your worker nodes.

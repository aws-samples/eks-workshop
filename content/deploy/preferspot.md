---
title: "Configure Node Affinity for Spot"
date: 2018-09-18T17:40:09-05:00
weight: 29
draft: false
---

We want our frontend service to be deployed on Spot Instances when they are available. We will use a nodeSelector statement in our manifest file to configure this.

1. Open the deployment manifest in your Cloud9 editor - **~/environment/ecsdemo-nodejs/kubernetes/deployment.yaml**
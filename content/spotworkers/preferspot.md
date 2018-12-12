---
title: "Configure Node Affinity for Spot"
date: 2018-09-18T17:40:09-05:00
weight: 30
draft: false
---

We want our frontend service to be deployed on Spot Instances when they are available. We will use Node Affinity in our manifest file to configure this.

Open the deployment manifest in your Cloud9 editor - **~/environment/ecsdemo-frontend/kubernetes/deployment.yaml**

Edit the spec to configure NodeAffinity to `prefer` Spot Instances, but not `require` them. This will allow the pods to be scheduled on On-Demand nodes if no spot instances were available or correctly labelled.

For examples of Node Affinity, check this [**link**](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity)

#### Challenge

**Configure Node Affinity**
{{% expand "Expand here to see the solution"%}}
Add this to your deployment file under spec.template.spec

```yaml
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: lifecycle
            operator: In
            values:
            - Ec2Spot
```

{{% notice tip %}}
 We have provided a solution file at the bottom of this page that you can use to compare.
{{% /notice %}}

{{% /expand %}}

{{%attachments title="Related files" pattern=".yml"/%}}
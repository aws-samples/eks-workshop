---
title: "Create a Chart"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

Helm charts have a structure similar to:

{{< output >}}
/eksdemo
  /Chart.yaml  # a description of the chart
  /values.yaml # defaults, may be overridden during install or upgrade
  /charts/ # May contain subcharts
  /templates/ # the template files themselves
  ...
{{< /output >}}

We'll follow this template, and create a new chart called **eksdemo** with the following commands:

```sh
cd ~/environment
helm create eksdemo
```

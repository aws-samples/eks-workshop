---
title: "Create a Chart"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

Helm charts have a structure similar to:

{{< output >}}
/eksdemo
├── charts/
├── Chart.yaml
├── templates/
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
{{< /output >}}

We'll follow this template, and create a new chart called **eksdemo** with the following commands:

```sh
cd ~/environment
helm create eksdemo
cd eksdemo
```

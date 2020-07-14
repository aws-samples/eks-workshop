---
title: "Preparing your Load Test"
chapter: false
weight: 7
---

Now that we have monitoring enabled we will simulate heavy load to our EKS Cluster hosting our Wordpress install. While generating the load, we can watch CloudWatch Container Insights for the performance metrics.

#### Install Siege for load testing on your Workspace

```bash
sudo yum install siege -y
```

Verify Siege is working by typing the below into your terminal window.

```bash
siege --version
```

Output example (version may vary).
{{< output >}}
SIEGE 3.0.8

Copyright (C) 2014 by Jeffrey Fulmer, et al.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.
{{< /output >}}

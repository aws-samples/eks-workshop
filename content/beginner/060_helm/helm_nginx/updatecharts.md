---
title: "Update the Chart Repository"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

Helm uses a packaging format called
[Charts](https://helm.sh/docs/topics/charts/). A Chart is a collection of files
and templates that describes Kubernetes resources.

Charts can be simple, describing something like a standalone web server (which
is what we are going to create), but they can also be more complex, for example,
a chart that represents a full web application stack, including web servers,
databases, proxies, etc.

Instead of installing Kubernetes resources manually via `kubectl`, one can use
Helm to install pre-defined Charts faster, with less chance of typos or other
operator errors.

Chart repositories change frequently due to updates and new additions.  To keep
Helm's local list updated with all these changes, we need to occasionally run
the [repository update](https://helm.sh/docs/helm/helm_repo_update) command.

To update Helm's local list of Charts, run:

```
# first, add the default repository, then update
helm repo add stable https://charts.helm.sh/stable
helm repo update
```

And you should see something similar to:

{{< output >}}
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
{{< /output >}}

Next, we'll search for the nginx web server Chart.

---
title: "Update the Chart Repository"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

Helm uses a packaging format called [Charts](https://v2.helm.sh/docs/developing_charts/#charts).  A Chart is a collection of files that describes k8s resources.

Charts can be simple, describing something like a standalone web server (which is what we are going to create), but they can also be more complex, for example, a chart that represents a full web application stack, including web servers, databases, proxies, etc.

Instead of installing k8s resources manually via kubectl, one can use Helm to install pre-defined Charts faster, with less chance of typos or other operator errors.

When you install Helm, you are provided with a default repository of Charts from the [official Helm Chart Repository](https://github.com/helm/charts/tree/master/stable).

This is a very dynamic list that always changes due to updates and new additions.  To keep Helm's local list updated with all these changes, we need to occasionally run the [repository update](https://v2.helm.sh/docs/helm/#helm-repo-update) command.

To update Helm's local list of Charts, run:

```
helm repo update
```

And you should see something similar to:

```
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

Next, we'll search for the NGINX web server Chart.

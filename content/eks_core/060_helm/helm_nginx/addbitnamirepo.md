---
title: "Add the Bitnami Repository"
date: 2018-08-07T08:30:11-07:00
weight: 300
---

In the last slide, we saw that nginx offers many different products via the
default Helm Chart repository, but the nginx standalone web server is not one of
them.

After a quick web search, we discover that there is a Chart for the nginx
standalone web server available via the [Bitnami Chart
repository](https://github.com/bitnami/charts).

To add the Bitnami Chart repo to our local list of searchable charts:

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once that completes, we can search all Bitnami Charts:

```sh
helm search repo bitnami
```

Which results in:

{{< output >}}
NAME                                    CHART VERSION   APP VERSION             DESCRIPTION
bitnami/bitnami-common                  0.0.8           0.0.8                   Chart with...
bitnami/apache                          4.3.3           1.10.9                  Chart for Apache...
bitnami/cassandra                       5.0.2           3.11.6                  Apache Cassandra...
...
{{< /output >}}

Search once again for nginx

```sh
helm search repo nginx
```

Now we are seeing more nginx options, across both repositories:

{{< output >}}
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/nginx                           5.1.6           1.16.1          Chart for the nginx server
bitnami/nginx-ingress-controller        5.3.4           0.29.0          Chart for the nginx Ingress...
stable/nginx-ingress                    1.30.3          0.28.0          An nginx Ingress controller ...
{{< /output >}}

Or even search the Bitnami repo, just for nginx:

```sh
helm search repo bitnami/nginx
```

Which narrows it down to nginx on Bitnami:

{{< output >}}
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/nginx                           5.1.6           1.16.1          Chart for the nginx server
bitnami/nginx-ingress-controller        5.3.4           0.29.0          Chart for the nginx Ingress...
{{< /output >}}

In both of those last two searches, we see

{{< output >}}
bitnami/nginx
{{< /output >}}

as a search result.  That's the one we're looking for, so let's use Helm to install it to the EKS cluster.

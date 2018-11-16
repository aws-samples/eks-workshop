---
title: "Search the Chart Repository"
date: 2018-08-07T08:30:11-07:00
weight: 200
---

Now that our repository Chart list has been updated, we can [search for Charts](https://docs.helm.sh/helm/#helm-search).

To list all Charts:

```
helm search
```

That should output something similiar to:

```
NAME                                    CHART VERSION   APP VERSION                     DESCRIPTION                                                 
stable/acs-engine-autoscaler            2.2.0           2.1.1                           Scales worker...
stable/aerospike                        0.1.7           v3.14.1.2                       A Helm chart...
...
```

You can see from the output that it dumped the list of all Charts it knows about.  In some cases that may be useful, but an even more useful search would involve a keyword argument.  So next, we'll search just for NGINX:

```
helm search nginx
```

That results in:

```
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                                 
stable/nginx-ingress            0.31.0          0.20.0          An nginx Ingress ...
stable/nginx-ldapauth-proxy     0.1.2           1.13.5          nginx proxy ...
stable/nginx-lego               0.3.1                           Chart for...
stable/gcloud-endpoints         0.1.2           1               DEPRECATED Develop...
...
```

This new list of Charts are specific to nginx, because we passed the **nginx** argument to the search command.

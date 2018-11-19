---
title: "Add the Bitnami Repository"
date: 2018-08-07T08:30:11-07:00
weight: 300
---

In the last slide, we saw that NGINX offers many different products via the default Helm Chart repository, but the NGINX standalone web server is not one of them.

After a quick web search, we discover that there is a Chart for the NGINX standalone web server available via the [Bitnami Chart repository](https://github.com/bitnami/charts).

To add the Bitnami Chart repo to our local list of searchable charts:

```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once that completes, we can search all Bitnami Charts:

```
helm search bitnami
```

Which results in:

```
NAME                                    CHART VERSION   APP VERSION             DESCRIPTION                                                 
bitnami/bitnami-common                  0.0.3           0.0.1                   Chart with...        
bitnami/apache                          2.1.2           2.4.37                  Chart for Apache...                              
bitnami/cassandra                       0.1.0           3.11.3                  Apache Cassandra...
...
```

Search once again for NGINX:

```
helm search nginx
```

Now we are seeing more NGINX options, across both repositories:

```
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                                 
bitnami/nginx                           1.1.2           1.14.1          Chart for the nginx server                                  
bitnami/nginx-ingress-controller        2.1.4           0.20.0          Chart for the nginx Ingress...                    
stable/nginx-ingress                    0.31.0          0.20.0          An nginx Ingress controller ...
```

Or even search the Bitnami repo, just for NGINX:

```
helm search bitnami/nginx
```

Which narrows it down to NGINX on Bitnami:

```
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                           
bitnami/nginx                           1.1.2           1.14.1          Chart for the nginx server            
bitnami/nginx-ingress-controller        2.1.4           0.20.0          Chart for the nginx Ingress...
```

In both of those last two searches, we see

```
bitnami/nginx
```

as a search result.  That's the one we're looking for, so let's use Helm to install it to the EKS cluster.

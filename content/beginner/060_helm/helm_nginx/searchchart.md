---
title: "Search the Chart Repository"
date: 2018-08-07T08:30:11-07:00
weight: 200
---

Now that our repository Chart list has been updated, we can [search for Charts](https://v2.helm.sh/docs/helm/#helm-search).

To list all Charts:

```sh
helm search repo
```

That should output something similar to:
{{< output >}}
NAME                                    CHART VERSION   APP VERSION             DESCRIPTION                                       
stable/acs-engine-autoscaler            2.2.2           2.1.1                   DEPRECATED Scales worker nodes within agent pools 
stable/aerospike                        0.3.2           v4.5.0.5                A Helm chart for Aerospike in Kubernetes          
stable/airflow                          6.0.1           1.10.4                  Airflow is a platform to programmatically autho...
stable/ambassador                       5.3.1           0.86.1                  A Helm chart for Datawire Ambassador              
 
 ...
{{< /output >}}

You can see from the output that it dumped the list of all Charts it knows about.  In some cases that may be useful, but an even more useful search would involve a keyword argument.  So next, we'll search just for NGINX:

```sh
helm search repo nginx
```

That results in:
{{< output >}}
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
stable/nginx-ingress            1.30.3          0.28.0          An nginx Ingress controller that uses ConfigMap...
stable/nginx-ldapauth-proxy     0.1.3           1.13.5          nginx proxy with ldapauth                         
stable/nginx-lego               0.3.1                           Chart for nginx-ingress-controller and kube-lego  
stable/gcloud-endpoints         0.1.2           1               DEPRECATED Develop, deploy, protect and monitor...
...
{{< /output >}}

This new list of Charts are specific to nginx, because we passed the **nginx** argument to the search command.

---
title: "Deploy Prometheus"
date: 2018-10-14T20:33:02-04:00
weight: 10
draft: false
---

#### Download Prometheus

```
curl -o prometheus-values.yaml https://raw.githubusercontent.com/helm/charts/master/stable/prometheus/values.yaml
```

Search for **# storageClass: "-"**, uncomment and change the value to **"prometheus"**. You will do this twice, under both **`server`** & **`alertmanager`** manifests

The manifests will look like below

```
    ## Prometheus server data Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: "prometheus"
```

```
    ## alertmanager data Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: "prometheus"
```

#### Deploy Prometheus
```
helm install -f prometheus-values.yaml stable/prometheus --name prometheus --namespace prometheus
```

Make a note of prometheus endpoint in helm response (you will need this later). It should look similar to below

```
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.prometheus.svc.cluster.local
```

You can access Prometheus server URL by running these commands
```
export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace prometheus port-forward $POD_NAME 9090
```

In your Cloud9 environment, click **Preview / Preview Running Application**. Scroll to **the end of the URL** and append **:9090/targets** to view cluster-level metrics

![prometheus-targets](/images/prometheus-targets.png)

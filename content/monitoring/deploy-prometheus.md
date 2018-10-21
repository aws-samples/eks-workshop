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

Search for **## List of IP addresses at which the Prometheus server service is available**, add **nodeport: 30900** and change the type to **NodePort** as indicated below. Because Prometheus is exposed as ClusterIP by default, the web UI cannot be reached outside of Kubernetes. The reason we are adding NodePort here is for viewing the web UI from worker node IP address. This configuration is not recommended in Production and there are better ways to secure it. You can read more about exposing Prometheus web UI in this [link](https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/exposing-prometheus-and-alertmanager.md)

```
## List of IP addresses at which the Prometheus server service is available
## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
##
externalIPs: []

loadBalancerIP: ""
loadBalancerSourceRanges: []
servicePort: 80
nodePort: 30900
type: NodePort
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
Check if Prometheus components deployed as expected
```
kubectl get all -n prometheus
```
You should see response similar to below. They should all be Ready and Available
```
NAME                                                 READY     STATUS    RESTARTS   AGE
pod/prometheus-alertmanager-77cfdf85db-s9p48         2/2       Running   0          1m
pod/prometheus-kube-state-metrics-74d5c694c7-vqtjd   1/1       Running   0          1m
pod/prometheus-node-exporter-6dhpw                   1/1       Running   0          1m
pod/prometheus-node-exporter-nrfkn                   1/1       Running   0          1m
pod/prometheus-node-exporter-rtrm8                   1/1       Running   0          1m
pod/prometheus-pushgateway-d5fdc4f5b-dbmrg           1/1       Running   0          1m
pod/prometheus-server-6d665b876-dsmh9                2/2       Running   0          1m

NAME                                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/prometheus-alertmanager         ClusterIP   10.100.89.154    <none>        80/TCP     1m
service/prometheus-kube-state-metrics   ClusterIP   None             <none>        80/TCP     1m
service/prometheus-node-exporter        ClusterIP   None             <none>        9100/TCP   1m
service/prometheus-pushgateway          ClusterIP   10.100.136.143   <none>        9091/TCP   1m
service/prometheus-server               ClusterIP   10.100.151.245   <none>        80/TCP     1m

NAME                                      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/prometheus-node-exporter   3         3         3         3            3           <none>          1m

NAME                                            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-alertmanager         1         1         1            1           1m
deployment.apps/prometheus-kube-state-metrics   1         1         1            1           1m
deployment.apps/prometheus-pushgateway          1         1         1            1           1m
deployment.apps/prometheus-server               1         1         1            1           1m

NAME                                                       DESIRED   CURRENT   READY     AGE
replicaset.apps/prometheus-alertmanager-77cfdf85db         1         1         1         1m
replicaset.apps/prometheus-kube-state-metrics-74d5c694c7   1         1         1         1m
replicaset.apps/prometheus-pushgateway-d5fdc4f5b           1         1         1         1m
replicaset.apps/prometheus-server-6d665b876                1         1         1         1m

```
You can access Prometheus server URL by going to any one of your Worker node IP address and specify port **:30900/targets** (for ex, <a href="http://52.12.161.128:30900/targets" data-proofer-ignore>http://52.12.161.128:30900/targets</a>). Remember to open port **30900** in your Worker nodes Security Group. In the web UI, you can see all the targets and metrics being monitored by Prometheus

![prometheus-targets](/images/prometheus-targets.png)

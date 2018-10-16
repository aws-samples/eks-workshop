---
title: "Deploy Grafana"
date: 2018-10-14T20:54:13-04:00
weight: 15
draft: true
---

#### Download Grafana

```
curl -o grafana-values.yaml https://raw.githubusercontent.com/helm/charts/master/stable/grafana/values.yaml
```

Search for **# storageClassName: default**, uncomment and change the value to **"prometheus"**
Search for **# adminPassword: strongpassword**, uncomment and change the password to **"EKS!sAWSome"** or something similar.

Search for **datasources: {}** and uncomment entire block, update prometheus to the endpoint referred earlier by helm response. The configuration will look similar to below

```
datasources:
 datasources.yaml:
   apiVersion: 1
   datasources:
   - name: Prometheus
     type: prometheus
     url: http://prometheus-server.prometheus.svc.cluster.local
     access: proxy
     isDefault: true
```

#### Deploy grafana

```
helm install -f grafana.yaml stable/grafana --name grafana --namespace grafana
```

#### Check if both prometheus and grafana pods are running
```
kubectl get all -n prometheus

kubectl get all -n grafana
```
You can access Grafana URL using these commands

```
export POD_NAME=$(kubectl get pods --namespace grafana -l "app=grafana" -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace grafana port-forward $POD_NAME 3000
```

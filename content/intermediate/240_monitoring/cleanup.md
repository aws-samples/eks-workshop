---
title: "Cleanup"
date: 2018-10-14T21:03:30-04:00
weight: 25
draft: false
---

#### Uninstall Prometheus and Grafana

```bash
helm uninstall prometheus --namespace prometheus
kubectl delete ns prometheus

helm uninstall grafana --namespace grafana
kubectl delete ns grafana

rm -rf ${HOME}/environment/grafana
```

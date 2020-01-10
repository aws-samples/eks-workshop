---
title: "Cleanup"
date: 2018-10-14T21:03:30-04:00
weight: 25
draft: false
---

#### Delete Prometheus and grafana
```
helm delete prometheus -n prometheus
helm del --purge prometheus -n prometheus
helm delete grafana -n grafana
helm del --purge grafana -n grafana
```

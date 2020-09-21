---
title: "Cleanup"
date: 2020-09-19T00:19:00+05:30
draft: false
weight: 90
tags:
  - beginner
  - CON203
---

Stop the proxy and delete the dashboard deployment

```bash
# kill proxy
pkill -f  pkill -f "kubectl port-forward -n kubenav svc/kubenav 14122"

# delete namespace kubenav
kubectl delete -n kubenav

```

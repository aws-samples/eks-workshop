---
title: "Cleanup Helm"
date: 2018-08-07T12:37:34-07:00
weight: 25
draft: false
---
We will remove the packages installed by Helm
```
helm del --purge metrics-server
helm reset --force
```

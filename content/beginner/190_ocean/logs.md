---
title: "Cluster Logs and Scaling Decisions"
date: 2019-04-09T00:00:00-03:00
weight: 18
draft: false
---

### Cluster Logs And Autoscaling Visibility

The final tab on the Ocean cluster dashboard is the log tab, which contains your cluster logs. Here you can look back at the various events occurring in the Cluster and filter by time, severity and resource ID.

<img src="/images/ocean/log_tab.png" alt="Log Tab" width="700"/>

Most importantly, you can gain deep visibility into the decisions made by Ocean's Autoscaler, and see the reason for each scaling activity by clicking on “View Details”. The details view will show you pre and post scale resource allocation, the reason for the scaling, and the affected resources.

<img src="/images/ocean/logs_scale_down.png" alt="Log Details" width="700"/>

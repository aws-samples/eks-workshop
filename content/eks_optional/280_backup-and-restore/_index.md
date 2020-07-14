---
title: "Backup and Restore using Velero"
chapter: true
weight: 280
draft: false
tags:
  - intermediate
  - operations
---

# Backup and Restore EKS using Velero

[Velero](https://velero.io/) (formerly Heptio Ark) is an open source tool to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes. 

Velero enables you to create on-demand and scheduled backups. When a backup or restore command is executed using velero cli, a custom resource, defined by a Kubernetes Custom Resource Definition (CRD), is created and stored in etcd. Velero controllers notice the new object created and processes the custom resources and performs the needed operation like backups, restores, and other related operations.

Velero let's you backup your entire cluster or namespace(s) or filter objects by using labels. Velero helps with migrating your on-prem Kubernetes workloads to cloud, cluster upgrades and disaster recovery.

In this module, you will learn how to backup and restore an EKS cluster using Velero. 

![Title Image](/images/backupandrestore/velero.png)

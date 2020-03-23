---
title: "Backup and Restore"
weight: 40
draft: false
---

#### Backup staging namespace using Velero

Let's backup the staging namespace using velero

```
velero backup create staging-backup --include-namespaces staging
```

Check the status of backup
```
velero backup describe staging-backup
```

Check if the Phase is Completed and if the snapshots are created.

Access Velero S3 bucket using AWS Managment Console and verify if 'staging-backup' have been created.

#### Simulate a disaster

Let's delelte the 'staging' namespace to simulate a disaster
```
kubectl delete namespace staging
```

Verify that MySQL and Wordpress are deleted
```
kubectl get all -n staging
```

#### Restore staging namespace

Run the velero restore command from the backup created
```
velero restore create --from-backup staging-backup
```

Verify if deployments, replicasets, services and pods are restored
```
kubectl get all -n staging
```

Access Wordpress service using port forwording
```
kubectl port-forward service/wordpress 8080:80 -n staging
```

Access the wordpress application at http://localhost:8080 from your Cloud9 Workspace and verify if the blog post you created is restored.
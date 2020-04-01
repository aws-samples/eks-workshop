---
title: "Deploy Test Application"
weight: 30
draft: false
---

#### Create namespace and install application

Let's create a new namespace and deploy an application in that namespace. We will deploy a Wordpress application and MySQL database backed by persistent volumes.

Create a namespace called 'staging'
```
kubectl create namespace staging
```

{{% notice info %}}
We will be using Amazon EBS CSI Driver to manage storage for this lab. 
{{% /notice %}}

Copy/Paste the following commands into your Cloud9 Terminal.
```
mkdir -p ~/environment/backup-restore
cd ~/environment/backup-restore
wget https://eksworkshop.com/intermediate/280_backup-and-restore/backupandrestore.files/storageclass.yaml
```
```
kubectl apply -f storageclass.yaml
```

#### Deploy Wordpress and MySQL in the staging namespace

Create a kubernetes secret for MySQL DB password

```
kubectl create secret generic mysql-pass --from-literal=password=velerodemo -n staging
```

```
cd ~/environment/backup-restore
wget https://eksworkshop.com/intermediate/280_backup-and-restore/backupandrestore.files/mysql-deployment.yaml
wget https://eksworkshop.com/intermediate/280_backup-and-restore/backupandrestore.files/wordpress-deployment.yaml
```

Deploy MySQL and Wordpress
```
kubectl apply -f mysql-deployment.yaml -n staging
kubectl apply -f wordpress-deployment.yaml -n staging
```

Verify deployment
```
kubectl get deployments -n staging
```

Verify Persistent Volume Claims
```
kubectl get pvc -n staging
```

Access Wordpress service using port forwording
```
kubectl port-forward service/wordpress 8080:80 -n staging
```

Access the wordpress application at http://localhost:8080 from your Cloud9 Workspace and create wordpress admin username and password.

![Token page](/images/backupandrestore/wordpress-admin.jpg)

Create a blog post for testing and publish it

![Token page](/images/backupandrestore/blogpost.jpg)

Logout and test the published blogpost

![Token page](/images/backupandrestore/wordpress.jpg)
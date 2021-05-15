---
title: "Update the application"
weight: 40
draft: false
---

Our application is now deployed into our ArgoCD. We are now going to update our github repository synced with our application

### Update your application
Go to your Github fork repository:

Update `spec.replicas: 2` in `ecsdemo-nodejs/kubernetes/deployment.yaml`
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecsdemo-nodejs
  labels:
    app: ecsdemo-nodejs
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecsdemo-nodejs
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: ecsdemo-nodejs
    spec:
      containers:
      - image: brentley/ecsdemo-nodejs:latest
        imagePullPolicy: Always
        name: ecsdemo-nodejs
        ports:
        - containerPort: 3000
          protocol: TCP
```
Add a commit message and click on `Commit changes`

### Access ArgoCD Web Interface
To deploy our change we can access to ArgoCD UI. Open your web browser and go to the Load Balancer url:
```
echo $ARGOCD_SERVER
```
Login using `admin` / `$ARGO_PWD`.
You now have access to the ecsdemo-nodejds application. After clicking to `refresh` button status should be `OutOfSync`:

![Fork url](/images/argocd/app_outofsync.png)

This means our Github repository is not synchronised with the deployed application. To fix this and deploy the new version (with 2 replicas) click on the `sync` button, and select the `APPS/DEPLOYMENT/DEFAULT/ECSDEMO-NODEJS` and `SYNCHRONIZE`:

![Fork url](/images/argocd/app_sync.png)

After the sync completed our application should have the `Synced` status with 2 pods:

![Fork url](/images/argocd/app_synced.png)

All those actions could have been made with the Argo CLI also. 


---
title: "Deploy an application"
weight: 30
draft: false
---

We now have an ArgoCD fully deployed, we will nos deploy an application (ecsdemo-nodejs)

### Fork application repository
First step is to create a fork for the Github application we will deploy

Login to github, go to: https://github.com/brentley/ecsdemo-nodejs.git and Fork the repo
![Fork Img](/images/argocd/fork_app_repo.jpg)

Then into your select the https Url by clicking into button `Clone or download`:
![Fork url](/images/argocd/fork_url.jpg)

This url will be needed when we will configure the application into ArgoCD.

### Create application

Connect with Argocd cli using our cluster context:
```
CONTEXT_NAME=`kubectl config view -o jsonpath='{.contexts[].name}'`
argocd cluster add $CONTEXT_NAME
```

{{% notice tip %}}
ArgoCD provide multicluster deployment functionalities. For the purpose of this workshop we will only deployed on the local cluster
{{% /notice %}}

Configure the application and link to your fork (replace the GITHUB_USERNAME):
```
kubectl create namespace ecsdemo-nodejs
argocd app create ecsdemo-nodejs --repo https://github.com/GITHUB_USERNAME/ecsdemo-nodejs.git --path kubernetes --dest-server https://kubernetes.default.svc --dest-namespace ecsdemo-nodejs
```

Application is now setup, let's have a look to the application deployed state:
```
argocd app get ecsdemo-nodejs
```

You should have this output:
```
Health Status:      Missing

GROUP       KIND              NAMESPACE         NAME              STATUS     HEALTH   HOOK  MESSAGE
_           Service           ecsdemo-nodejs    ecsdemo-nodejs    OutOfSync  Missing        
apps        Deployment        default           ecsdemo-nodejs    OutOfSync  Missing        
```

We can wee that the application is in an `OutOfSync` status since the application has not been deployed yet. 
We are now going to `sync` our application:
```
argocd app sync ecsdemo-nodejs
```

After a couple of minutes our application should be synchronized 
```
GROUP  KIND        NAMESPACE       NAME            STATUS  HEALTH   HOOK  MESSAGE
_      Service     ecsdemo-nodejs  ecsdemo-nodejs  Synced  Healthy        service/ecsdemo-nodejs created
apps   Deployment  default         ecsdemo-nodejs  Synced  Healthy        deployment.apps/ecsdemo-nodejs created
```


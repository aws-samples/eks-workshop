---
title: "Deploy from Helm"
date: 2018-10-087T08:30:11-07:00
weight: 30
draft: false
---

You can use this same approach to deploy Helm charts.  These charts can exist within the configuration Git repository (k8s-config), or hosted from an external chart repository.  In this example we will use an external chart to keep things simple.  

In your k8s-config directory, create a namespace manifest.

{{% notice info %}}
The **git pull** command ensures we have the latest configuration in case Flux modified anything.
{{% /notice %}}

```
cd ../k8s-config

git pull 

cat << EOF > namespaces/nginx.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    name: nginx
  name: nginx
EOF
```

Now create a Helm release manifest.  This is a custom resource definition provided by Weave Flux. 

```
cat << EOF > releases/nginx.yaml
---
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: mywebserver
  namespace: nginx
  annotations:
    flux.weave.works/automated: "true"
    flux.weave.works/tag.nginx: semver:~1.16
    flux.weave.works/locked: 'true'
    flux.weave.works/locked_msg: '"Halt updates for now"'
    flux.weave.works/locked_user: User Name <user@example.com>
spec:
  releaseName: mywebserver
  chart:
    repository: https://charts.bitnami.com/bitnami/
    name: nginx
    version: 11.1.5
  values:
    usePassword: true
    image:
      registry: public.ecr.aws
      repository: bitnami/nginx
      tag: 1.21.6
    service:
      type: LoadBalancer
      port: 80
      nodePorts:
        http: ""
      externalTrafficPolicy: Cluster
    ingress:
      enabled: false
    metrics:
      enabled: false
EOF
```

You will notice a few additional annotations above.  

* flux.weave.works/locked tells Flux to lock the deployment so a new image version will not be deployed.  
* flux.weave.works/tag.nginx filters the images available by semantic versioning.   

Now commit the changes and wait up to 5 minutes for Flux to pull in the configuration.  

```
git add . 
git commit -am "Adding nginx helm release"
git push
```

Verify the deployment as follows. 

{{% notice info %}}
Use your pod name below for **kubectl logs**
{{% /notice %}}

```
kubectl get pods -n flux
kubectl logs flux-5bd7fb6bb6-4sc78 -n flux

helm list
kubectl get all -n nginx
```

If this doesn't deploy, check to ensure helm was initialized.  Also, look at the Flux Helm operator to see if there are any errors.  

```
kubectl get pods -n flux
kubectl logs flux-helm-operator-df5746688-84kw8 -n flux
```

Verify the Nginx service as follows.

```
kubectl get service -n nginx 
```

You've now seen how Weave Flux can enable a GitOps approach to deployment. 

---
title: "Install bitnami/nginx"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

Installing the Bitnami standalone NGINX web server Chart involves us using the [helm install](https://docs.helm.sh/helm/#helm-install) command.

When we install using Helm, we need to provide a deployment name, or a random one will be assigned to the deployment automatically.

Let's provide **mywebserver** as the deployment name as we install NGINX:

```
helm install --name mywebserver bitnami/nginx
```
Upon running this command, you should see some confirmations around the objects that were created:

```
NAME:   mywebserver
LAST DEPLOYED: Tue Nov 13 19:55:25 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1beta1/Deployment
NAME               AGE
mywebserver-nginx  0s

==> v1/Pod(related)

NAME                                READY  STATUS             RESTARTS  AGE
mywebserver-nginx-85985c8466-tczst  0/1    ContainerCreating  0         0s

==> v1/Service

NAME               AGE
mywebserver-nginx  0s
```
Let's use **kubectl** to verify each of these components that were just created for us.  Do note that it may take a minute or two for each of these objects' **DESIRED** and **CURRENT** values to match; if they don't match on the first try, wait a few seconds, and run the command again to check the status.

To verify the pod object was successfully deployed:

```
kubectl get pods -l app=mywebserver-nginx
```
And you should see output similiar to:

```
NAME                                 READY     STATUS    RESTARTS   AGE
mywebserver-nginx-85985c8466-tczst   1/1       Running   0          10s
```
The Service enables us to contact this NGINX web server from the Internet, via an Elastic Load Balancer (ELB).  To get the complete URL of this service:

```
kubectl get service mywebserver-nginx -o wide
```

That should output something similar to:

```
NAME                TYPE           CLUSTER-IP      EXTERNAL-IP                                                              
mywebserver-nginx   LoadBalancer   10.100.223.99   abc123.amazonaws.com
```

Copy the value for **EXTERNAL-IP**, open a new tab in your web browser, and paste it in.  It may take a couple minutes for the ELB and its associated DNS name to become available; if you get an error, wait one minute, and hit reload.

When the service does come online, you should see a welcome message similar to:

![Helm Logo](/images/helm-nginx/welcome_to_nginx.png)

Congrats!  You've now successfully deployed the NGINX standalone web server to your EKS cluster!

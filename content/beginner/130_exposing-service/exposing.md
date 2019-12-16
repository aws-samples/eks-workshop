---
title: "Exposing the Service"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---
#### Exposing the Service
For some parts of your applications you may want to expose a Service onto an external IP address. Kubernetes supports two ways of doing this: NodePorts and LoadBalancers. 
```
kubectl get svc my-nginx
```
Output
{{< output >}}
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
my-nginx   ClusterIP   10.100.225.196   <none>        80/TCP    33m
{{< /output >}}
Currently the Service does not have an External IP, so let’s now recreate the Service to use a cloud load balancer, just change the Type of my-nginx Service from `ClusterIP` to `LoadBalancer`:
```
kubectl edit svc my-nginx
```
Once edited, we can check for the changes:
```
kubectl get svc my-nginx
```
Output
{{< output >}}
NAME       TYPE           CLUSTER-IP       EXTERNAL-IP                                                             PORT(S)        AGE
my-nginx   LoadBalancer   10.100.225.196   aca434079a4cb0a9961170c1-23367063.us-west-2.elb.amazonaws.com           80:30470/TCP   39m
{{< /output >}}
Now, let's try if it's accesible. The ELB can take a couple of minutes in being available on the DNS.
```
curl http://<EXTERNAL-IP> -k
```
Output
{{< output >}}
<title>Welcome to nginx!</title>
{{< /output >}}


The IP address in the EXTERNAL-IP column is the one that is available on the public internet. The CLUSTER-IP is only available inside your cluster/private cloud network.

If the Load Balancer name is too long to fit in the standard kubectl get svc output, you’ll need to do kubectl describe service my-nginx to see it. You’ll see something like this:
```
kubectl describe service my-nginx | grep Ingress
```
Output
{{< output >}}
LoadBalancer Ingress:   a320587ffd19711e5a37606cf4a74574-1142138393.us-east-1.elb.amazonaws.com
{{< /output >}}


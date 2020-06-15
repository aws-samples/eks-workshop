---
title: "Connecting Applications with Services"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

Before discussing the Kubernetes approach to networking, it is worthwhile to contrast it with the “normal” way networking works with Docker.

By default, Docker uses host-private networking, so containers can talk to other containers only if they are on the same machine. In order for Docker containers to communicate across nodes, there must be allocated ports on the machine’s own IP address, which are then forwarded or proxied to the containers. This obviously means that containers must either coordinate which ports they use very carefully or ports must be allocated dynamically.

Coordinating ports across multiple developers is very difficult to do at scale and exposes users to cluster-level issues outside of their control. Kubernetes assumes that pods can communicate with other pods, regardless of which host they land on. We give every pod its own cluster-private-IP address so you do not need to explicitly create links between pods or map container ports to host ports. This means that containers within a Pod can all reach each other’s ports on localhost, and all pods in a cluster can see each other without NAT. 

#### Exposing pods to the cluster

If you created a default deny policy in the previous section, delete it by running:
```
kubectl delete -f ~/environment/calico_resources/default-deny.yaml 
```
Create an nginx Pod, and note that it has a container port specification:

```
cat <<EoF > ~/environment/run-my-nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EoF
```

This makes it accessible from any node in your cluster. Check the nodes the Pod is running on:

```
kubectl apply -f ~/environment/run-my-nginx.yaml
kubectl get pods -l run=my-nginx -o wide
```
The output being something like this:
{{< output >}}
NAME                        READY     STATUS    RESTARTS   AGE       IP               NODE                                           NOMINATED NODE
my-nginx-756f645cd7-gsl4g   1/1       Running   0          63s       192.168.59.188   ip-192-168-38-150.us-west-2.compute.internal   <none>
my-nginx-756f645cd7-t8b6w   1/1       Running   0          63s       192.168.79.210   ip-192-168-92-222.us-west-2.compute.internal   <none>
{{< /output >}}
Check your pods’ IPs:
```
kubectl get pods -l run=my-nginx -o yaml | grep podIP
```
Output being like:
{{< output >}}
    podIP: 192.168.59.188
    podIP: 192.168.79.210
{{< /output >}}


#### Creating a Service
So we have pods running nginx in a flat, cluster wide, address space. In theory, you could talk to these pods directly, but what happens when a node dies? The pods die with it, and the Deployment will create new ones, with different IPs. This is the problem a Service solves.

A Kubernetes Service is an abstraction which defines a logical set of Pods running somewhere in your cluster, that all provide the same functionality. When created, each Service is assigned a unique IP address (also called clusterIP). This address is tied to the lifespan of the Service, and will not change while the Service is alive. Pods can be configured to talk to the Service, and know that communication to the Service will be automatically load-balanced out to some pod that is a member of the Service.

You can create a Service for your 2 nginx replicas with kubectl expose:
```
kubectl expose deployment/my-nginx
```
Output:
{{< output >}}
service/my-nginx exposed
{{< /output >}}

This specification will create a Service which targets TCP port 80 on any Pod with the run: my-nginx label, and expose it on an abstracted Service port (targetPort: is the port the container accepts traffic on, port: is the abstracted Service port, which can be any port other pods use to access the Service). View Service API object to see the list of supported fields in service definition. Check your Service:
```
kubectl get svc my-nginx
```

{{< output >}}
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
my-nginx   ClusterIP   10.100.225.196   <none>        80/TCP    25s
{{< /output >}}
As mentioned previously, a Service is backed by a group of Pods. These Pods are exposed through endpoints. The Service’s selector will be evaluated continuously and the results will be POSTed to an Endpoints object also named my-nginx. When a Pod dies, it is automatically removed from the endpoints, and new Pods matching the Service’s selector will automatically get added to the endpoints. Check the endpoints, and note that the IPs are the same as the Pods created in the first step:
```
kubectl describe svc my-nginx
```
{{< output >}}
Name:              my-nginx
Namespace:         default
Labels:            run=my-nginx
Annotations:       <none>
Selector:          run=my-nginx
Type:              ClusterIP
IP:                10.100.225.196
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         192.168.59.188:80,192.168.79.210:80
Session Affinity:  None
Events:            <none>
{{< /output >}}

You should now be able to curl the nginx Service on <CLUSTER-IP>:<PORT> from any node in your cluster. Note that the Service IP is completely virtual, it never hits the wire. Let's try that
```
kubectl run -i --tty load-generator --image=busybox /bin/sh
```
To go into the cluster and then try with the ClusterIP:
```
wget -q -O - 10.100.225.196
```
The output will be
{{< output >}}
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
{{< /output >}}
To exit, just make a ctrl+D

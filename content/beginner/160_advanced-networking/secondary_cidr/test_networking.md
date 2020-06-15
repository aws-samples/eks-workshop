---
title: "Test Networking"
date: 2019-03-02T15:18:32-05:00
weight: 50
---

### Launch pods into Secondary CIDR network

Let's launch few pods and test networking
```
kubectl run nginx --image=nginx
kubectl scale --replicas=3 deployments/nginx
kubectl expose deployment/nginx --type=NodePort --port 80
kubectl get pods -o wide
```
{{< output >}}
NAME                     READY     STATUS    RESTARTS   AGE       IP              NODE                                           NOMINATED NODE
nginx-64f497f8fd-k962k   1/1       Running   0          40m       100.64.6.147    ip-192-168-52-113.us-east-2.compute.internal   <none>
nginx-64f497f8fd-lkslh   1/1       Running   0          40m       100.64.53.10    ip-192-168-74-125.us-east-2.compute.internal   <none>
nginx-64f497f8fd-sgz6f   1/1       Running   0          40m       100.64.80.186   ip-192-168-26-65.us-east-2.compute.internal    <none>
{{< /output >}}
You can use busybox pod and ping pods within same host or across hosts using IP address

```
kubectl run -i --rm --tty debug --image=busybox -- sh
```
Test access to internet and to nginx service
{{< output >}}
# connect to internet
/ # wget google.com -O -
Connecting to google.com (172.217.5.238:80)
Connecting to www.google.com (172.217.5.228:80)
<!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="en"><head><meta content="Search the world's information, including webpages, images, videos and more. Google has many special
...

# connect to service (testing core-dns)
/ # wget nginx -O -
Connecting to nginx (10.100.170.156:80)
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
{{< /output >}}

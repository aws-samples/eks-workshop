---
title: "Accessing the Service"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

#### Accessing the Service
Kubernetes supports 2 primary modes of finding a Service - environment variables and DNS. The former works out of the box while the latter requires the CoreDNS cluster addon.

#### Environment Variables
When a Pod runs on a Node, the kubelet adds a set of environment variables for each active Service. This introduces an ordering problem. To see why, inspect the environment of your running nginx Pods (your Pod name will be different):
Let's view the pods again:
```
kubectl get pods -l run=my-nginx -o wide
```
Output:
{{< output >}}
NAME                        READY     STATUS    RESTARTS   AGE       IP               NODE                                           NOMINATED NODE
my-nginx-756f645cd7-gsl4g   1/1       Running   0          22m       192.168.59.188   ip-192-168-38-150.us-west-2.compute.internal   <none>
my-nginx-756f645cd7-t8b6w   1/1       Running   0          22m       192.168.79.210   ip-192-168-92-222.us-west-2.compute.internal   <none>
{{< /output >}}
Now let's inspect the environment of your running nginx Pods (your Pod name will be different):
```
kubectl exec my-nginx-3800858182-jr4a2 -- printenv | grep SERVICE
```
{{< output >}}
KUBERNETES_SERVICE_PORT_HTTPS=443
TEST_SERVICE_HOST=10.100.36.158
TEST_SERVICE_PORT=80
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.100.0.1
{{< /output >}}

Note there’s no mention of your Service. This is because you created the replicas before the Service. Another disadvantage of doing this is that the scheduler might put both Pods on the same machine, which will take your entire Service down if it dies. We can do this the right way by killing the 2 Pods and waiting for the Deployment to recreate them. This time around the Service exists before the replicas. This will give you scheduler-level Service spreading of your Pods (provided all your nodes have equal capacity), as well as the right environment variables:
```
kubectl scale deployment my-nginx --replicas=0 
kubectl scale deployment my-nginx --replicas=2
```
```
kubectl get pods -l run=my-nginx -o wide
```
Output just in the moment of change:
{{< output >}}
NAME                        READY     STATUS        RESTARTS   AGE       IP               NODE                                           NOMINATED NODE
my-nginx-756f645cd7-9tgkw   1/1       Running       0          6s        192.168.14.67    ip-192-168-15-64.us-west-2.compute.internal    <none>
my-nginx-756f645cd7-gsl4g   0/1       Terminating   0          25m       192.168.59.188   ip-192-168-38-150.us-west-2.compute.internal   <none>
my-nginx-756f645cd7-ljjgq   1/1       Running       0          6s        192.168.63.80    ip-192-168-38-150.us-west-2.compute.internal   <none>
my-nginx-756f645cd7-t8b6w   0/1       Terminating   0          25m       192.168.79.210   ip-192-168-92-222.us-west-2.compute.internal   <none>
{{< /output >}}
You may notice that the pods have different names, since they are killed and recreated.

```
kubectl exec my-nginx-3800858182-e9ihh -- printenv | grep SERVICE
```
{{< output >}}
MY_NGINX_SERVICE_HOST=10.100.225.196
TEST_SERVICE_HOST=10.100.36.158
MY_NGINX_SERVICE_PORT=80
KUBERNETES_SERVICE_HOST=10.100.0.1
KUBERNETES_SERVICE_PORT=443
TEST_SERVICE_PORT=80
KUBERNETES_SERVICE_PORT_HTTPS=443
{{< /output >}}

#### DNS
Kubernetes offers a DNS cluster addon Service that automatically assigns dns names to other Services. You can check if it’s running on your cluster:

```
kubectl get services kube-dns --namespace=kube-system
```
{{< output >}}
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns   ClusterIP   10.0.0.10    <none>        53/UDP,53/TCP   8m
{{< /output >}}
If it isn’t running, you can enable it. The rest of this section will assume you have a Service with a long lived IP (my-nginx), and a DNS server that has assigned a name to that IP (the CoreDNS cluster addon), so you can talk to the Service from any pod in your cluster using standard methods (e.g. gethostbyname). Let’s run another curl application to test this:

```
kubectl run curl --image=radial/busyboxplus:curl -i --tty
```
Output:
{{< output >}}
Waiting for pod default/curl-131556218-9fnch to be running, status is Pending, pod ready: false
Hit enter for command prompt
{{< /output >}}
Then, hit enter and run 
```
nslookup my-nginx
```
Output:
{{< output >}}
Server:    10.100.0.10
Server:    10.100.0.10
Address 1: 10.100.0.10 kube-dns.kube-system.svc.cluster.local

Name:      my-nginx
Address 1: 10.100.225.196 my-nginx.default.svc.cluster.local
{{< /output >}}

```bash
exit

```

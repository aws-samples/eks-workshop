---
title: "Create Resources"
date: 2018-08-07T08:30:11-07:00
weight: 1
---

Before creating network polices, let's create the required resources.

First, clone the Github repo containing all the manifests:
```
git clone https://github.com/nikipat/calico_resources.git
```
Create a namespace called stars:

```
cd ~/environment/calico_resources
kubectl apply -f 00-namespace.yaml
```
We will create frontend and backend [replication controllers](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/) and [services](https://kubernetes.io/docs/concepts/services-networking/service/) in this namespace in later steps.


Create a management-ui namespace, with a management-ui service and replication controller within that namespace:

```
kubectl apply -f 01-management-ui.yaml
```
Create frontend and backend replication controllers and services within the stars namespace:

```
kubectl apply -f 02-backend.yaml
kubectl apply -f 03-frontend.yaml
```
Lastly, create a client namespace, and a client service for a replication controller:

```
kubectl apply -f 04-client.yaml
```
Check their status, and wait for all the pods to reach the Running status:

```
$ kubectl get pods --all-namespaces
```
Your output should look like this:

```
NAMESPACE       NAME                                                  READY   STATUS    RESTARTS   AGE
client          client-nkcfg                                          1/1     Running   0          24m
kube-system     aws-node-6kqmw                                        1/1     Running   0          50m
kube-system     aws-node-grstb                                        1/1     Running   1          50m
kube-system     aws-node-m7jg8                                        1/1     Running   1          50m
kube-system     calico-node-b5b7j                                     1/1     Running   0          28m
kube-system     calico-node-dw694                                     1/1     Running   0          28m
kube-system     calico-node-vtz9k                                     1/1     Running   0          28m
kube-system     calico-typha-75667d89cb-4q4zx                         1/1     Running   0          28m
kube-system     calico-typha-horizontal-autoscaler-78f747b679-kzzwq   1/1     Running   0          28m
kube-system     kube-dns-7cc87d595-bd9hq                              3/3     Running   0          1h
kube-system     kube-proxy-lp4vw                                      1/1     Running   0          50m
kube-system     kube-proxy-rfljb                                      1/1     Running   0          50m
kube-system     kube-proxy-wzlqg                                      1/1     Running   0          50m
management-ui   management-ui-wzvz4                                   1/1     Running   0          24m
stars           backend-tkjrx                                         1/1     Running   0          24m
stars           frontend-q4r84                                        1/1     Running   0          24m
```

{{% notice note %}}
It may take several minutes to download all the required Docker images.
{{% /notice %}}

To summarize the different resources we created:

* A namespace called 'stars'
* 'frontend' and 'backend' replication controllers and services within 'stars' namespace
* A namespace called 'management-ui'
* Replication controller and service 'management-ui' for the user interface seen on the browser, in the 'management-ui' namespace
* A namespace called 'client'
* 'client' replication controller and service in 'client' namespace

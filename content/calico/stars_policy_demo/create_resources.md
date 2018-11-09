---
title: "Create Resources"
date: 2018-08-07T08:30:11-07:00
weight: 1
---

Before creating network polices, let's create the required resources.

Create a namespace called [stars](https://docs.projectcalico.org/v3.2/getting-started/kubernetes/tutorials/stars-policy/manifests/00-namespace.yaml). We will create frontend and backend services in this namespace in later steps

```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/manifests/00-namespace.yaml
```

[Create](https://docs.projectcalico.org/v3.2/getting-started/kubernetes/tutorials/stars-policy/manifests/01-management-ui.yaml) a management-ui namespace, with a management-ui service and [replication controller](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/) within that namespace.

```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/manifests/01-management-ui.yaml
```
Create [frontend](https://docs.projectcalico.org/v3.2/getting-started/kubernetes/tutorials/stars-policy/manifests/03-frontend.yaml) and [backend](https://docs.projectcalico.org/v3.2/getting-started/kubernetes/tutorials/stars-policy/manifests/02-backend.yaml) services within the stars namespace:

```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/manifests/02-backend.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/manifests/03-frontend.yaml
```
Lastly, [create](https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/manifests/04-client.yaml) a client namespace, and a client service for a replication controller:

```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/manifests/04-client.yaml
```
Check their status, and wait for all the pods to reach the Running status:

```
$ kubectl get pods --all-namespaces
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
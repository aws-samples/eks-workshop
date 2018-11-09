---
title: "Apply Network Policies"
date: 2018-08-07T08:30:11-07:00
weight: 3
---
In a production level cluster, it is not secure to have open pod to pod communication. Let's see how we can isolate the services from each other. Apply the following network policies in stars namespace (frontend and backend services) and client namespace (client service):

```
kubectl apply -n stars -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/policies/default-deny.yaml
kubectl apply -n client -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/policies/default-deny.yaml
```
Upon refreshing your browser, you see that the management UI cannot reach any of the nodes, so nothing shows up in the UI.

Network policies in Kubernetes use labels to select pods, and define rules on what traffic is allowed to reach those pods. They may specify ingress or egress or both. Each rule allows traffic which matches both the from and ports sections.

Let's go over the [network policy](https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/policies/default-deny.yaml) we just applied:

```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
spec:
  podSelector:
    matchLabels: {}
```
Here we see the podSelector does not have any matchLabels, essentially blocking all the pods from accessing it.

Apply the following network policies to allow the management UI to access the frontend, backend and client services:

```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/policies/allow-ui.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/stars-policy/policies/allow-ui-client.yaml
```
Upon refreshing your browser, you can see that the management UI can reach all the services, but they cannot communicate with each other.

![Management UI access all services](/images/calico-mgmtui-access.png)

---
title: "Apply Network Policies"
date: 2018-08-07T08:30:11-07:00
weight: 3
---
In a production level cluster, it is not secure to have open pod to pod communication. Let's see how we can isolate the services from each other.

Save this NetworkPolicy as `default-deny.yaml`.

```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
spec:
  podSelector:
    matchLabels: {}
```

Let's go over the network policy. Here we see the podSelector does not have any matchLabels, essentially blocking all the pods from accessing it.

Apply the network policy in the `stars` namespace (frontend and backend services) and the `client` namespace (client service):

```
kubectl apply -n stars -f default-deny.yaml
kubectl apply -n client -f default-deny.yaml
```

Upon refreshing your browser, you see that the management UI cannot reach any of the nodes, so nothing shows up in the UI.

Network policies in Kubernetes use labels to select pods, and define rules on what traffic is allowed to reach those pods. They may specify ingress or egress or both. Each rule allows traffic which matches both the from and ports sections.

Create two new network policies.

##### `allow-ui.yaml`
```
kind: NetworkPolicy
apiVersion: extensions/v1beta1 
metadata:
  namespace: stars
  name: allow-ui 
spec:
  podSelector:
    matchLabels: {}
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              role: management-ui
```

##### `allow-ui-client.yaml`
```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: client 
  name: allow-ui 
spec:
  podSelector:
    matchLabels: {}
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              role: management-ui
```

Apply the following network policies to allow the management UI to access the frontend, backend and client services:

```
kubectl apply -f allow-ui.yaml
kubectl apply -f allow-ui-client.yaml
```
Upon refreshing your browser, you can see that the management UI can reach all the services, but they cannot communicate with each other.

![Management UI access all services](/images/calico-mgmtui-access.png)

---
title: "Allow Directional Traffic"
date: 2018-08-07T08:30:11-07:00
weight: 4
---
Let's see how we can allow directional traffic from client to frontend and backend.

To allow traffic from frontend service to the backend service apply the following manifest:

```
kubectl apply -f backend-policy.yaml
```

And allow traffic from the client namespace to the frontend service:

```
kubectl apply -f frontend-policy.yaml
```
Upon refreshing your browser, you should be able to see the network policies in action:

![directional traffic](/images/calico-client-f-b-access.png)

Let's have a look at the backend-policy. Its spec has a podSelector that selects all pods with the label **role:backend**, and allows ingress from all pods that have the label **role:frontend** and on TCP port **6379**, but not the other way round. Traffic is allowed in one direction on a specific port number.

```
spec:
  podSelector:
    matchLabels:
      role: backend
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 6379
```
The frontend-policy is similar, except it allows ingress from **namespaces** that have the label **role: client** on TCP port **80**.

```
spec:
  podSelector:
    matchLabels:
      role: frontend 
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              role: client
      ports:
        - protocol: TCP
          port: 80
```

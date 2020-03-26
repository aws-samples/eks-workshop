---
title: "Allow Directional Traffic"
date: 2018-08-07T08:30:11-07:00
weight: 4
---
Let's see how we can allow directional traffic from client to frontend, and from frontend to backend.

Copy/Paste the following commands into your Cloud9 Terminal.
```
cd ~/environment/calico_resources
wget https://eksworkshop.com/beginner/120_network-policies/calico/stars_policy_demo/directional_traffic.files/backend-policy.yaml
wget https://eksworkshop.com/beginner/120_network-policies/calico/stars_policy_demo/directional_traffic.files/frontend-policy.yaml
```

Let's examine this backend policy with `cat backend-policy.yaml`:
{{< output >}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: stars
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      role: backend
  ingress:
    - from:
        - <EDIT: UPDATE WITH THE CONFIGURATION NEEDED TO WHITELIST FRONTEND USING PODSELECTOR>
      ports:
        - protocol: TCP
          port: 6379
{{< /output >}}
#### Challenge:
**After reviewing the manifest, you'll see we have intentionally left few of the configuration fields for you to EDIT. Please edit the configuration as suggested. You can find helpful info in this [Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)**

{{% expand "Expand here to see the solution"%}}
{{< output >}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: stars
  name: backend-policy
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
{{< /output >}}
{{%/expand%}}

Let's examine the frontend policy with `cat frontend-policy.yaml`:

{{< output >}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: stars
  name: frontend-policy
spec:
  podSelector:
    matchLabels:
      role: frontend
  ingress:
    - from:
        - <EDIT: UPDATE WITH THE CONFIGURATION NEEDED TO WHITELIST CLIENT USING NAMESPACESELECTOR>
      ports:
        - protocol: TCP
          port: 80
{{< /output >}}
#### Challenge:
**Please edit the configuration as suggested. You can find helpful info in this [Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)**

{{% expand "Expand here to see the solution"%}}
{{< output >}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: stars
  name: frontend-policy
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
{{< /output >}}
{{%/expand%}}
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

{{< output >}}
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
{{< /output >}}

The frontend-policy is similar, except it allows ingress from **namespaces** that have the label **role: client** on TCP port **80**.

{{< output >}}
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
{{< /output >}}

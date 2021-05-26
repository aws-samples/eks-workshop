---
title: "Deploy sample application"
date: 2021-05-26T00:00:00-03:00
weight: 30
---

### Deploy nginx pod on a Bottlerocket node

Create a namespace
```bash
kubectl create namespace bottlerocket-nginx
```

Create a simple nginx pod config:

```bash
cat <<EoF > ~/environment/bottlerocket-nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: bottlerocket-nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    role: bottlerocket
EoF
```

Deploy the application:

```bash
kubectl create -f ~/environment/bottlerocket-nginx.yaml
```

Next, run the following command to confirm the new application is running on a bottlerocket node:

```bash
kubectl describe pod/nginx -n bottlerocket-nginx
```

Output: 
{{< output >}}
Node:         ip-192-168-70-50.us-east-2.compute.internal/192.168.70.50
{{< /output >}}
---
title: "Pod Priority and Preemption"
date: 2020-06-22T00:00:00-03:00
weight: 13
draft: false
---

Pod Priority is used to apply importance of a pod relative to other pods. In this section we will create two `PriorityClasses` and watch the interaction of pods. 


### Create PriorityClass

We will create two `PriorityClass`, **low-priority** and **high-priority**.

```
cat <<EoF > ~/environment/resource-management/high-priority-class.yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 100
globalDefault: false
description: "High-priority Pods"
EoF

kubectl apply -f ~/environment/resource-management/high-priority-class.yml


cat <<EoF > ~/environment/resource-management/low-priority-class.yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 50
globalDefault: false
description: "Low-priority Pods"
EoF

kubectl apply -f ~/environment/resource-management/low-priority-class.yml

```

{{% notice info %}}
Pods with without a  `PriorityClass` are 0. A global `PriorityClass` can be assigned. Additional details can be found [here](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass) 
{{% /notice %}}

## Deploy low-priority Pods

Next we will deploy low-priority pods to use up resources on the nodes. The goal is to saturate the nodes with as many pods as possible. 
```
cat <<EoF > ~/environment/resource-management/low-priority-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 50
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      priorityClassName: "low-priority"      
      containers:            
       - image: nginx
         name: nginx-deployment
         resources:
           limits:
              memory: 1G  
EoF
kubectl apply -f ~/environment/resource-management/low-priority-deployment.yml
```

Watch the number of available pods in the `Deployment` until the available stabilizes around a number. This exercise does not require all pods in the deployment to be in Available state. We want to ensure the nodes are completely filled with pods. It may take up to 2 minutes to stabilize. 

```
kubectl get deployment nginx-deployment --watch
```
Output:
{{< output >}}
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   5/50    50           5           5s
nginx-deployment   6/50    50           6           6s
...
nginx-deployment   21/50   50           21          20s
nginx-deployment   21/50   50           21          6m
{{< /output >}}

### Deploy High Priority Pod

In a new terminal watch `Deployment` using the command below

```
kubectl get deployment --watch
```

Next deploy high-priority `Deployment` to see the how Kubernetes handles `PriorityClass`. 

```
cat <<EoF > ~/environment/resource-management/high-priority-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: high-nginx-deployment
  name: high-nginx-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: high-nginx-deployment
  template:
    metadata:
      labels:
        app: high-nginx-deployment
    spec:
      priorityClassName: "high-priority"      
      containers:            
       - image: nginx
         name: high-nginx-deployment
         resources:
           limits:
              memory: 1G
EoF
kubectl apply -f ~/environment/resource-management/high-priority-deployment.yml
```

What changes did you see?
{{% expand "Expand for output" %}}
{{< output >}}
kubectl get deployment  --watch
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   21/50   50           21          2m15s

high-nginx-deployment   0/5     0            0           0s
high-nginx-deployment   0/5     0            0           0s
high-nginx-deployment   0/5     0            0           0s
high-nginx-deployment   0/5     5            0           0s
nginx-deployment        20/50   49           20          4m9s
nginx-deployment        20/50   50           20          4m9s
nginx-deployment        19/50   49           19          4m9s
nginx-deployment        19/50   50           19          4m9s
nginx-deployment        18/50   49           18          4m9s
nginx-deployment        18/50   50           18          4m9s
nginx-deployment        17/50   49           17          4m9s
nginx-deployment        17/50   50           17          4m9s
nginx-deployment        16/50   49           16          4m9s
nginx-deployment        16/50   50           16          4m9s
high-nginx-deployment   1/5     5            1           8s
high-nginx-deployment   2/5     5            2           8s
high-nginx-deployment   3/5     5            3           22s
high-nginx-deployment   4/5     5            4           23s
high-nginx-deployment   5/5     5            5           23s
{{< /output >}}

When the higher-priority deployment is created it started to remove lower-priority pods on the nodes.  

{{% /expand %}}

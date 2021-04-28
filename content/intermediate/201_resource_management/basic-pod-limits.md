---
title: "Basic Pod CPU and Memory Management"
date: 2020-06-22T00:00:00-03:00
weight: 10
draft: false
---

We will create four pods:

  - A **request** deployment with `Request` cpu = 0.5 and memory = 1G
  - A **limit-cpu** deployment with `Limit` cpu = 0.5 and memory = 1G
  - A **limit-memory** deployment with `Limit` cpu = 1 and memory = 1G
  - A **restricted** deployment with `Request` of cpu = 1/memory = 1G and `Limit` cpu = 1.8/memory=2G


### Deploy Metrics Server
Follow the instructions in the module [Deploy the Metrics Server](/beginner/080_scaling/deploy_hpa/#deploy-the-metrics-server) to enable the Kubernetes Metrics Server.

Verify that the metrics-server deployment is running the desired number of pods with the following command.
```sh
kubectl get deployment metrics-server -n kube-system
```
Output:
{{< output >}}
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           19s
{{< /output >}}

{{% notice info %}}
CPU units are expressed as 1 CPU or 1000m, which equals to 1vCPU/Core. Additional details can be found [here](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) 
{{% /notice %}}

### Deploy Pods

In order to generate cpu and memory load we will use [stress-ng](http://manpages.ubuntu.com/manpages/bionic/man1/stress-ng.1.html) with the following flags. 

- **vm-keep:** maintain consistent memory usage
- **vm-bytes:** bytes given to each worker
- **vm:** number of workers to spawn ex. vm=1 uses 1000m CPU vm=2 uses 2000m CPU
- **oomable:** will not respawn after being killed by OOM killer
- **verbose:** show all information output
- **timeout:** length of test


```sh
# Deploy Limits pod with hard limit on cpu at 500m but wants 1000m
kubectl run --limits=memory=1G,cpu=0.5 --image  hande007/stress-ng basic-limit-cpu-pod --restart=Never --  --vm-keep --vm-bytes 512m --timeout 600s --vm 1 --oomable --verbose 

# Deploy Request pod with soft limit on memory 
kubectl run --requests=memory=1G,cpu=0.5 --image  hande007/stress-ng basic-request-pod --restart=Never --  --vm-keep   --vm-bytes 2g --timeout 600s --vm 1 --oomable --verbose 

# Deploy restricted pod with limits and requests wants cpu 2 and memory at 1G
kubectl run --requests=cpu=1,memory=1G --limits=cpu=1.8,memory=2G --image  hande007/stress-ng basic-restricted-pod  --restart=Never --  --vm-keep  --vm-bytes 1g --timeout 600s --vm 2 --oomable --verbose 

# Deploy Limits pod with hard limit on memory at 1G but wants 2G
kubectl run --limits=memory=1G,cpu=1 --image  hande007/stress-ng basic-limit-memory-pod --restart=Never --  --vm-keep  --vm-bytes 2g --timeout 600s --vm 1 --oomable --verbose 
```

### Verify Current Resource Usage

Check if pods are running properly. It is expected that **basic-limit-memory-pod** is not not running due to it asking for 2G of memory when it is assigned a `Limit` of 1G.

```
kubectl get pod
```
Output:
{{< output >}}
NAME                     READY   STATUS      RESTARTS   AGE
basic-limit-cpu-pod      1/1     Running     0          69s
basic-limit-memory-pod   0/1     OOMKilled   0          68s
basic-request-pod        1/1     Running     0          68s
basic-restricted-pod     1/1     Running     0          67s
{{< /output >}}

Next we check the current utilization

```
# After at least 60 seconds of generating metrics
kubectl top pod
```
Output:
{{< output >}}
NAME                   CPU(cores)   MEMORY(bytes)   
basic-limit-cpu-pod    501m         516Mi           
basic-request-pod      1000m        2055Mi          
basic-restricted-pod   1795m        1029Mi 
{{< / output >}}

{{% notice info%}}
Running multiple stress-ng on the same node will consume less CPU per pod. For example if the expected CPU is 1000 but only running 505 there may be other pods on the nodes consuming CPU. 
{{% / notice %}}

Kubernetes `Requests` and `Limits` can be applied to higher level abstractions like `Deployment`. 
{{% expand "Expand here to see the example"%}}
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: stress-deployment
  name: stress-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stress-deployment
  template:
    metadata:
      labels:
        app: stress-deployment
    spec:
      containers:
      - args:
        - --vm-keep
        - --vm-bytes
        - 1500m
        - --timeout
        - 600s
        - --vm
        - "3"
        - --oomable
        - --verbose
        image: hande007/stress-ng
        name: stress-deployment
        resources:
          limits:
            cpu: 2200m
            memory: 2G
          requests:
            cpu: "1"
            memory: 1G
```
{{% /expand %}}

### Cleanup
Clean up the pods before moving on to free up resources
```
kubectl delete pod basic-request-pod
kubectl delete pod basic-limit-memory-pod
kubectl delete pod basic-limit-cpu-pod
kubectl delete pod basic-restricted-pod
```

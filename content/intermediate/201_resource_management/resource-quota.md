---
title: "Resource Quotas"
date: 2020-06-22T00:00:00-03:00
weight: 12
draft: false
---

`ResourceQuotas` are used to limit resources like cpu,memory, storage, and services. In this section we will set up `ResourceQuotas` between two teams blue and red.


```
# Create different namespaces
kubectl create namespace blue
kubectl create namespace red
```
### Create Resource Quota
In this example environment we have two teams are sharing the same resources. The Red team is limited on number of Load Balancers provisioned and Blue team is restricted on memory/cpu usage. 

```
kubectl create quota blue-team --hard=limits.cpu=1,limits.memory=1G --namespace blue
kubectl create quota red-team --hard=services.loadbalancers=1 --namespace red
```

{{% notice info %}}
A list of objects that quotas can be applied to can be found [here](https://kubernetes.io/docs/concepts/policy/resource-quotas/) 
{{% /notice %}}

### Create Pods 

In next steps we will evaluate failed and successful attempts at creating resources.

##### Failed Attempts
Errors will occur when creating pods outside of the `ResourceQuota` specifications.
```
# Error when creating a resource without defined limit
kubectl run --namespace blue --image hande007/stress-ng blue-cpu-pod --restart=Never --  --vm-keep --vm-bytes 512m --timeout 600s --vm 2 --oomable --verbose

# Error when creating a deployment without specifying limits (Replicaset has errors)
kubectl create --namespace blue deployment blue-cpu-deploy --image hande007/stress-ng
kubectl describe --namespace blue replicaset -l app=blue-cpu-deploy  

# Error when creating more than one AWS Load Balancer
kubectl run --namespace red --image nginx:latest red-nginx-pod --restart=Never --limits=cpu=0.1,memory=100M
kubectl expose --namespace red pod red-nginx-pod --port 80 --type=LoadBalancer --name red-nginx-service-1
kubectl expose --namespace red pod red-nginx-pod --port 80 --type=LoadBalancer --name red-nginx-service-2
```
##### Successful Attempts
We create resources in blue namespace to use 75% of allocated resources
```
# Create Pod
kubectl run --namespace blue --limits=cpu=0.25,memory=250M --image nginx blue-nginx-pod-1 --restart=Never --restart=Never
kubectl run --namespace blue --limits=cpu=0.25,memory=250M --image nginx blue-nginx-pod-2 --restart=Never --restart=Never
kubectl run --namespace blue --limits=cpu=0.25,memory=250M --image nginx blue-nginx-pod-3 --restart=Never --restart=Never
```
### Verify Current Resource Quota Usage
We can query `ResourceQuota` to see current utilization. 
```
kubectl describe quota blue-team --namespace blue
kubectl describe quota red-team --namespace red
```


### Clean Up 
Clean up the pods before moving on to free up resources
```
kubectl delete namespace red
kubectl delete namespace blue
```
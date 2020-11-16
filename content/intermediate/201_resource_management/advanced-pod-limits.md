---
title: "Advanced Pod CPU and Memory Management"
date: 2020-06-22T00:00:00-03:00
weight: 11
draft: false
---


In the previous section, we created CPU and Memory constraints at the pod level. `LimitRange` are used to constraint compute, storage or enforce ratio between `Request` and `Limit` in a `Namespace`. In this section, we will separate the compute workloads by **low-usage**, **high-usage** and **unrestricted-usage**. 

We will create three `Namespaces`:

```
mkdir ~/environment/resource-management

kubectl create namespace low-usage
kubectl create namespace high-usage
kubectl create namespace unrestricted-usage
```

### Create Limit Ranges

Create `LimitRange` specification for **low-usage** and **high-usage** namespace level. The **unrestricted-usage** will not have any limits enforced. 
```
cat <<EoF > ~/environment/resource-management/low-usage-limit-range.yml
apiVersion: v1
kind: LimitRange
metadata:
  name: low-usage-range
spec:
  limits:
  - max:
      cpu: 1
      memory: 300M 
    min:
      cpu: 0.5
      memory: 100M
    type: Container
EoF

kubectl apply -f ~/environment/resource-management/low-usage-limit-range.yml --namespace low-usage


cat <<EoF > ~/environment/resource-management/high-usage-limit-range.yml
apiVersion: v1
kind: LimitRange
metadata:
  name: high-usage-range
spec:
  limits:
  - max:
      cpu: 2
      memory: 2G 
    min:
      cpu: 1
      memory: 1G
    type: Container
EoF

kubectl apply -f ~/environment/resource-management/high-usage-limit-range.yml --namespace high-usage
```
### Deploy Pods

Next we will deploy the pods to the nodes .

##### Failed Attempts
 Creating a pod with values outside what is defined in the `LimitRange` in the namespace will cause an errors
```sh
# Error due to higher memory request than defined in low-usage namespace: wanted 1g memory above max of 300m
kubectl run --namespace low-usage --requests=memory=1G,cpu=0.5 --image  hande007/stress-ng basic-request-pod --restart=Never --  --vm-keep   --vm-bytes 2g --timeout 600s --vm 1 --oomable --verbose 

# Error due to lower cpu request than defined in high-usage namespace: wanted 0.5 below min of 1
kubectl run --namespace high-usage --requests=memory=1G,cpu=0.5 --image  hande007/stress-ng basic-request-pod --restart=Never --  --vm-keep   --vm-bytes 2g --timeout 600s --vm 1 --oomable --verbose 
```

##### Successful Attempts
Create pods without specifying `Requests` or `Limits` will inherit `LimitRange` values.
```
kubectl run --namespace low-usage --image  hande007/stress-ng low-usage-pod --restart=Never --  --vm-keep   --vm-bytes 200m --timeout 600s --vm 2 --oomable --verbose 
kubectl run --namespace high-usage  --image  hande007/stress-ng high-usage-pod --restart=Never --  --vm-keep   --vm-bytes 200m --timeout 600s --vm 2 --oomable --verbose 
kubectl run --namespace unrestricted-usage --image  hande007/stress-ng unrestricted-usage-pod --restart=Never --  --vm-keep   --vm-bytes 200m --timeout 600s --vm 2 --oomable --verbose 
```

### Verify Pod Limits
Next we will verify that `LimitRange` values are being inherited by the pods in each namespace.

```
eval 'kubectl  -n='{low-usage,high-usage,unrestricted-usage}' get pod -o=custom-columns='Name:spec.containers[*].name','Namespace:metadata.namespace','Limits:spec.containers[*].resources.limits';'
```
Output:
{{< output >}}
Name            Namespace   Limits
low-usage-pod   low-usage   map[cpu:1 memory:300M]
Name             Namespace    Limits
high-usage-pod   high-usage   map[cpu:2 memory:2G]
Name                     Namespace            Limits
unrestricted-usage-pod   unrestricted-usage   <none>
{{< /output >}}


### Cleanup 
Clean up before moving on to free up resources
```
kubectl delete namespace low-usage
kubectl delete namespace high-usage
kubectl delete namespace unrestricted-usage
```
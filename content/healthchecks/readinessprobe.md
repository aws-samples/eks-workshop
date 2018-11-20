---
title: "Configure Readiness Probe"
chapter: true
weight: 10
---

# Configure Readiness Probe

```
kubectl apply -f ~/environment/healthchecks/readiness-deployment.yaml
```

The above command creates a deployment with 3 replicas and readiness probe as described in ~/environment/healthchecks/readiness-deployment.yaml.


```
kubectl get pods -l app=readiness-deployment
```

The output looks similar to below

```

NAME                                    READY     STATUS    RESTARTS   AGE
readiness-deployment-7869b5d679-922mx   1/1       Running   0          31s
readiness-deployment-7869b5d679-vd55d   1/1       Running   0          31s
readiness-deployment-7869b5d679-vxb6g   1/1       Running   0          31s
```

Let us also confirm that all the replicas are available to serve traffic when a service is pointed to this deployment.

```
kubectl describe deployment readiness-deployment | grep Replicas:
```

The output looks like below

```
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
```

Pick one of the pods from above 3 and issue a command as below to terminate the node process which makes the readiness probe fail.

```
kubectl exec -it readiness-deployment-<pod> -- rm /tmp/healthy
```

readiness-deployment-7869b5d679-922mx was picked from above to remove the file which is supposed to be present for the health check to pass. Below is the status after issuing the command.

```
kubectl get pods -l app=readiness-deployment
```

The output looks similar to below

```

NAME                                    READY     STATUS    RESTARTS   AGE
readiness-deployment-7869b5d679-922mx   0/1       Running   0          4m
readiness-deployment-7869b5d679-vd55d   1/1       Running   0          4m
readiness-deployment-7869b5d679-vxb6g   1/1       Running   0          4m
```

We will now check for the replicas that are available to serve traffic when a service is pointed to this deployment.

```
kubectl describe deployment readiness-deployment | grep Replicas:
```

The output looks like below

```
Replicas:               3 desired | 3 updated | 3 total | 2 available | 1 unavailable
```

It is confirmed that traffic will not be routed to the first pod in above deployment . The ready column confirms that the readiness probe for this pod did not pass and hence was marked as not ready. Once the pod passes the probe, it gets marked as ready and will receive any traffic.

When the readiness probe for a pod fails, the endpoints controller removes the pod from list of endpoints of all services that match the pod.

Run the below command to let the readiness probe for selected pod passes and describe the deployment to confirm all the pods are healthy.

```
kubectl exec -it readiness-deployment-<pod> -- touch /tmp/healthy
```

In the next section, we will cleanup the resources created to demonstrate liveness and readiness probes.

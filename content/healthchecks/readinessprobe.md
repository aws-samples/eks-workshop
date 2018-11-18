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

NAME                                    READY     STATUS    RESTARTS   AGE
readiness-deployment-7869b5d679-922mx   1/1       Running   0          31s
readiness-deployment-7869b5d679-vd55d   1/1       Running   0          31s
readiness-deployment-7869b5d679-vxb6g   1/1       Running   0          31s
```

Pick one of the pods from above 3 and issue a command as below to terminate the node process which makes the readiness probe fail.

```
kubectl exec -it readiness-deployment-<pod> -- /bin/kill -s SIGUSR1 1
```

readiness-deployment-7869b5d679-922mx was picked from above to terminate the node process and below is the status after issuing the command.

```
kubectl get pods -l app=readiness-deployment

NAME                                    READY     STATUS    RESTARTS   AGE
readiness-deployment-7869b5d679-922mx   0/1       Running   0          4m
readiness-deployment-7869b5d679-vd55d   1/1       Running   0          4m
readiness-deployment-7869b5d679-vxb6g   1/1       Running   0          4m
```

It is confirmed that traffic will not be routed to the first pod in above deployment . The ready column confirms that the readiness probe for this pod did not pass and hence marked as not ready. Once the pod passes the probe, it gets marked as ready and will receive any traffic.

In the next section, we will cleanup the resources created to demonstrate liveness and readiness probes.

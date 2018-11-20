---
title: "Configure Readiness Probe"
chapter: true
weight: 10
---

# Configure Readiness Probe

Save the text from following block as ~/environment/healthchecks/readiness-deployment.yaml. The readinessProbe definition explains how a linux command can be configured as healthcheck. We create an empty file /tmp/healthy to configure readiness probe and use the same to understand how kubelet helps to update a deployment with only healthy pods.  


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: readiness-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: readiness-deployment
  template:
    metadata:
      labels:
        app: readiness-deployment
    spec:
      containers:
      - name: readiness-deployment
        image: alpine
        command: ["sh", "-c", "touch /tmp/healthy && sleep 86400"]
        readinessProbe:
          exec:
            command:
            - cat
            - /tmp/healthy
          initialDelaySeconds: 5
          periodSeconds: 3

```

You may also download readiness-deployment.yaml file with the following commands

```
cd ~/environment/healthchecks
wget https://eksworkshop.com/healthchecks/readiness.files/readiness-deployment.yaml
```

We will now create a deployment to test readiness probe

```
kubectl apply -f ~/environment/healthchecks/readiness-deployment.yaml
```

The above command creates a deployment with 3 replicas and readiness probe as described in the beginning


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

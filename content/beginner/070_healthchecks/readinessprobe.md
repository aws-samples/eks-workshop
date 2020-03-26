---
title: "Configure Readiness Probe"
chapter: false
weight: 10
---

#### Configure the Probe

Run the following code block to populate **~/environment/healthchecks/readiness-deployment.yaml**. The readinessProbe definition explains how a linux command can be configured as healthcheck. We create an empty file **/tmp/healthy** to configure readiness probe and use the same to understand how kubelet helps to update a deployment with only healthy pods. 

```
cat <<EoF > ~/environment/healthchecks/readiness-deployment.yaml
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
EoF
```

We will now create a deployment to test readiness probe:

```
kubectl apply -f ~/environment/healthchecks/readiness-deployment.yaml
```

The above command creates a deployment with 3 replicas and readiness probe as described in the beginning.

```
kubectl get pods -l app=readiness-deployment
```

The output looks similar to below:

{{< output >}}

NAME                                    READY     STATUS    RESTARTS   AGE
readiness-deployment-7869b5d679-922mx   1/1       Running   0          31s
readiness-deployment-7869b5d679-vd55d   1/1       Running   0          31s
readiness-deployment-7869b5d679-vxb6g   1/1       Running   0          31s
{{< /output >}}

Let us also confirm that all the replicas are available to serve traffic when a service is pointed to this deployment.

```
kubectl describe deployment readiness-deployment | grep Replicas:
```

The output looks like below:

{{< output >}}
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
{{< /output >}}

#### Introduce a Failure
Pick one of the pods from above 3 and issue a command as below to delete the **/tmp/healthy** file which makes the readiness probe fail.

```
kubectl exec -it <YOUR-READINESS-POD-NAME> -- rm /tmp/healthy
```

**readiness-deployment-7869b5d679-922mx** was picked in our example cluster. The **/tmp/healthy** file was deleted. This file must be present for the readiness check to pass. Below is the status after issuing the command.

```
kubectl get pods -l app=readiness-deployment
```

The output looks similar to below:
{{< output >}}
NAME                                    READY     STATUS    RESTARTS   AGE
readiness-deployment-7869b5d679-922mx   0/1       Running   0          4m
readiness-deployment-7869b5d679-vd55d   1/1       Running   0          4m
readiness-deployment-7869b5d679-vxb6g   1/1       Running   0          4m
{{< /output >}}
Traffic will not be routed to the first pod in the above deployment. The ready column confirms that the readiness probe for this pod did not pass and hence was marked as not ready. 

We will now check for the replicas that are available to serve traffic when a service is pointed to this deployment.

```
kubectl describe deployment readiness-deployment | grep Replicas:
```

The output looks like below:

{{< output >}}
Replicas:               3 desired | 3 updated | 3 total | 2 available | 1 unavailable
{{< /output >}}

When the readiness probe for a pod fails, the endpoints controller removes the pod from list of endpoints of all services that match the pod.

#### Challenge: 
**How would you restore the pod to Ready status?**
{{%expand "Expand here to see the solution" %}}
Run the below command with the name of the pod to recreate the **/tmp/healthy** file. Once the pod passes the probe, it gets marked as ready and will begin to receive traffic again.

```
kubectl exec -it <YOUR-READINESS-POD-NAME> -- touch /tmp/healthy
```
```
kubectl get pods -l app=readiness-deployment
```
{{% /expand %}}

---
title: "Configure Liveness Probe"
chapter: true
weight: 5
---

# Configure Liveness Probe

```
kubectl apply -f ~/environment/healthchecks/liveness-app.yaml
```

The above command creates a pod with liveness probe as described in ~/environment/healthchecks/liveness-app.yaml.

```
kubectl get pod liveness-app
```

The output looks like below

```
NAME           READY     STATUS    RESTARTS   AGE
liveness-app   1/1       Running   0          11s
```

```
kubectl describe pod liveness-app
```

Above command when issued shows an output which ends as following:

```
Events:
  Type    Reason                 Age   From                                    Message
  ----    ------                 ----  ----                                    -------
  Normal  Scheduled              38s   default-scheduler                       Successfully assigned liveness-app to ip-192-168-18-63.ec2.internal
  Normal  SuccessfulMountVolume  38s   kubelet, ip-192-168-18-63.ec2.internal  MountVolume.SetUp succeeded for volume "default-token-8bmt2"
  Normal  Pulling                37s   kubelet, ip-192-168-18-63.ec2.internal  pulling image "brentley/ecsdemo-nodejs"
  Normal  Pulled                 37s   kubelet, ip-192-168-18-63.ec2.internal  Successfully pulled image "brentley/ecsdemo-nodejs"
  Normal  Created                37s   kubelet, ip-192-168-18-63.ec2.internal  Created container
  Normal  Started                37s   kubelet, ip-192-168-18-63.ec2.internal  Started container
```

We will issue the next command to send a SIGUSR1 signal to the nodejs application

```
kubectl exec -it liveness-app -- /bin/kill -s SIGUSR1 1
```

Describe the pod after waiting for 15-20 seconds and output has a trail as below

```
Events:
  Type     Reason                 Age                From                                    Message
  ----     ------                 ----               ----                                    -------
  Normal   Scheduled              1m                 default-scheduler                       Successfully assigned liveness-app to ip-192-168-18-63.ec2.internal
  Normal   SuccessfulMountVolume  1m                 kubelet, ip-192-168-18-63.ec2.internal  MountVolume.SetUp succeeded for volume "default-token-8bmt2"
  Warning  Unhealthy              30s (x3 over 40s)  kubelet, ip-192-168-18-63.ec2.internal  Liveness probe failed: Get http://192.168.13.176:3000/health: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
  Normal   Pulling                0s (x2 over 1m)    kubelet, ip-192-168-18-63.ec2.internal  pulling image "brentley/ecsdemo-nodejs"
  Normal   Pulled                 0s (x2 over 1m)    kubelet, ip-192-168-18-63.ec2.internal  Successfully pulled image "brentley/ecsdemo-nodejs"
  Normal   Created                0s (x2 over 1m)    kubelet, ip-192-168-18-63.ec2.internal  Created container
  Normal   Started                0s (x2 over 1m)    kubelet, ip-192-168-18-63.ec2.internal  Started container
  Normal   Killing                0s                 kubelet, ip-192-168-18-63.ec2.internal  Killing container with id docker://liveness:Container failed liveness probe.. Container will be killed and recreated.
```

When the nodejs application entered a debug mode with SIGUSR1 signal it did not respond to the health check pings and kubelet killed the container. The container was subject to the default restart policy

```
kubectl get pod liveness-app
```

The output looks like below

```
NAME           READY     STATUS    RESTARTS   AGE
liveness-app   1/1       Running   1          12m
```

We will now run a similar exercise for readiness probe in next section.

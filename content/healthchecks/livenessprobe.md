---
title: "Configure Liveness Probe"
chapter: false
weight: 5
---

#### Configure the Probe


Use the command below to create a directory

```
mkdir -p ~/environment/healthchecks
```

Save the manifest as ~/environment/healthchecks/liveness-app.yaml using your favorite editor. You can review the manifest that is described below. In the configuration file, livenessProbe determines how kubelet should check the Container in order to consider whether it is healthy or not. kubelet uses periodSeconds field to do frequent check on the Container. In this case, kubelet checks liveness probe every 5 seconds. initialDelaySeconds field is to tell the kubelet that it should wait for 5 seconds before doing the first probe. To perform a probe, kubelet sends a HTTP GET request to the server hosting this Pod and if the handler for the servers /health returns a success code, then the Container is considered healthy. If the handler returns a failure code, the kubelet kills the Container and restarts it.

```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-app
spec:
  containers:
  - name: liveness
    image: brentley/ecsdemo-nodejs
    livenessProbe:
      httpGet:
        path: /health
        port: 3000
      initialDelaySeconds: 5
      periodSeconds: 5
```

Let's create the pod using the manifest

```
kubectl apply -f ~/environment/healthchecks/liveness-app.yaml
```

The above command creates a pod with liveness probe

```
kubectl get pod liveness-app
```
The output looks like below. Notice the ***RESTARTS***

```
NAME           READY     STATUS    RESTARTS   AGE
liveness-app   1/1       Running   0          11s
```

The `kubectl describe` command will show an event history which will show any probe failures or restarts.
```bash
kubectl describe pod liveness-app
```

```text
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


#### Introduce a Failure
We will run the next command to send a SIGUSR1 signal to the nodejs application. By issuing this command we will send a kill signal to the application process in docker runtime.

```
kubectl exec -it liveness-app -- /bin/kill -s SIGUSR1 1
```

Describe the pod after waiting for 15-20 seconds and you will notice kubelet actions of killing the Container and restarting it. 
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

When the nodejs application entered a debug mode with SIGUSR1 signal, it did not respond to the health check pings and kubelet killed the container. The container was subject to the default restart policy.

```
kubectl get pod liveness-app
```

The output looks like below

```
NAME           READY     STATUS    RESTARTS   AGE
liveness-app   1/1       Running   1          12m
```

#### Challenge:
**How can we check the status of the container health checks?**

{{%expand "Expand here to see the solution" %}}
```bash
kubectl logs liveness-app
```
You can also use `kubectl logs` to retrieve logs from a previous instantiation of a container with `--previous flag`, in case the container has crashed
```bash
kubectl logs liveness-app --previous
```
```text
<Output omitted>
Example app listening on port 3000!
::ffff:192.168.43.7 - - [20/Nov/2018:22:53:01 +0000] "GET /health HTTP/1.1" 200 16 "-" "kube-probe/1.10"
::ffff:192.168.43.7 - - [20/Nov/2018:22:53:06 +0000] "GET /health HTTP/1.1" 200 17 "-" "kube-probe/1.10"
::ffff:192.168.43.7 - - [20/Nov/2018:22:53:11 +0000] "GET /health HTTP/1.1" 200 17 "-" "kube-probe/1.10"
Starting debugger agent.
Debugger listening on [::]:5858
```
{{% /expand %}}

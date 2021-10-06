---
title: "Test Network Policies"
date: 2018-11-08T08:30:11-07:00
weight: 3
---

We to define the Windows and Linux deployments by running the following command.

```
cat << EOF > ~/environment/windows/sample-deployments.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx-deployment
    namespace: windows
spec:
    selector:
        matchLabels:
            app: nginx
    replicas: 1
    template:
        metadata:
            labels:
                app: nginx
        spec:
            containers:
            - name: nginx
              image: nginx:1.7.9
              securityContext:
                privileged: true
            nodeSelector:
                beta.kubernetes.io/os: linux
EOF
```

We can now deploy those pods in our cluster.

```
kubectl apply -f ~/environment/windows/sample-deployments.yaml
```

Verify that the pods are in ‘Running’ state.

```
kubectl get pods -o wide --watch -n windows
```

Output:

{{< output >}}
NAME                                  READY   STATUS    RESTARTS   AGE   IP                NODE                                           NOMINATED NODE   READINESS GATES
nginx-deployment-54b55f86cd-7x6jm     1/1     Running   0          19s   192.168.177.232   ip-192-168-168-60.us-east-2.compute.internal   <none>           <none>
windows-server-iis-7cff879775-zmrj6   1/1     Running   0          63m   192.168.18.152    ip-192-168-5-189.us-east-2.compute.internal    <none>           <none>
{{< /output >}}


Test ping connectivity between pods

We would start by verifying that there is network connectivity among all pods. Inside each pod, ping the other two pods’ IP. Update the <nginx-pod-name> below with the pod name that you see in the cluster.

```
kubectl -n windows exec -it <nginx-pod-name> -- /bin/bash
```

Now ping the IP of the Windows pod

```
ping <windows-pod-ip>
```

 Output: (Note: Control + C to stop the ping test):

```
root@nginx-deployment-54b55f86cd-7x6jm:/# ping 192.168.18.152 
PING 192.168.18.152 (192.168.18.152): 48 data bytes                                                                                                                                                                            
56 bytes from 192.168.18.152: icmp_seq=0 ttl=127 time=1.480 ms                                                                                                                                                                 
56 bytes from 192.168.18.152: icmp_seq=1 ttl=127 time=1.599 ms                                                                                                                                                                 
56 bytes from 192.168.18.152: icmp_seq=2 ttl=127 time=1.481 ms                                                                                                                                                                 
56 bytes from 192.168.18.152: icmp_seq=3 ttl=127 time=6.054 ms                                                                                                                                                                 
^C--- 192.168.18.152 ping statistics ---                                                                                                                                                                                       
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max/stddev = 1.480/2.654/6.054/1.964 ms
```

Now we will exit the Nginx pod by typing "exit" and pressing enter


Similarly, ‘exec’ into one of the Windows pods as well. Update the <windows-pod-name> below with the pod names that you see in the cluster.

```
kubectl -n windows exec -it <windows-pod-name> -- powershell
```
Now ping the IP of the Nginx pod

```
ping <nginx-pod-ip>
```

Output:

```
PS C:\> ping 192.168.177.232                                                                                                                                                                                                   
                                                                                                                                                                                                                               
Pinging 192.168.177.232 with 32 bytes of data:                                                                                                                                                                                 
Reply from 192.168.177.232: bytes=32 time=1ms TTL=254                                                                                                                                                                          
Reply from 192.168.177.232: bytes=32 time=1ms TTL=254                                                                                                                                                                          
Reply from 192.168.177.232: bytes=32 time=8ms TTL=254                                                                                                                                                                          
Reply from 192.168.177.232: bytes=32 time=1ms TTL=254                                                                                                                                                                          
                                                                                                                                                                                                                               
Ping statistics for 192.168.177.232:                                                                                                                                                                                           
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),                                                                                                                                                                       
Approximate round trip times in milli-seconds:                                                                                                                                                                                 
    Minimum = 1ms, Maximum = 8ms, Average = 2ms                                                                                                                                                                                
PS C:\> exit                                  
```

Exit the Windows pod by typing "exit" and pressing enter.

Now that we have established basic connectivity accross pods, let's enforce a network policy to restrict ping connectivity.

We could use Kubectl to apply the the network policies but Calico has a CLI that offers policy validation and will protect the cluster from malformed policies. 

Install the Calicoctl pod and create an alias to access this functionality

```
kubectl apply -f https://docs.projectcalico.org/archive/v3.15/manifests/calicoctl.yaml 
alias calicoctl="kubectl exec -i -n kube-system calicoctl -- /calicoctl"
```

Create and apply the network policy specification to deny ping traffic to all pods.

```
cat << EOF > ~/environment/windows/deny_icmp.yaml
---
kind: GlobalNetworkPolicy
apiVersion: projectcalico.org/v3
metadata:
    name: block-icmp
spec:
  order: 200
  selector: all()
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
    protocol: ICMP
  - action: Deny
    protocol: ICMPv6
  egress:
  - action: Deny
    protocol: ICMP
  - action: Deny
    protocol: ICMPv6
EOF

calicoctl apply -f - < ~/environment/windows/deny_icmp.yaml
```
Now we will test ping connectivity between pods just like we did above.

We can exec into the <nginx-pod-name> and when we try to ping the windows machine we will see 100% packet loss.

```
kubectl exec -it <nginx-pod-name> /bin/bash
```

Now ping the IP of the Windows pod

```
ping <windows-pod-ip>
```

Output:

{{< output >}}
root@nginx-deployment-54b55f86cd-jr662:/# ping 192.168.18.1
PING 192.168.18.1 (192.168.18.1): 48 data bytes
^C--- 192.168.18.1 ping statistics ---
24 packets transmitted, 0 packets received, 100% packet loss
{{< /output >}}

As you can see we are no longer able to ping the windows pod. Now we will exit the Nginx pod by typing "exit" and pressing enter.

If you want you could exec into the <windows-pod-name> pod and you will also be blocked from pinging the nginx pod.

That is it! You have configured your Windows worker nodes with Open source Calico for Windows and testing using the network policies.
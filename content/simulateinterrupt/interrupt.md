---
title: "Simulate interruption"
weight: 30
draft: false
---

1. Once you are able to see the nodes, we are ready to reduce the target capacity down by 1.
 
2. Navigate in your EC2 dashboard to the Spot Requests in your left hand menu. Click on it.

3. This will show you the open spot requests. Look at the request starting with *sfr-* This is the spot fleet request you would have created.

4. Click on that, and click on the *Actions* button above, and select *Modify Target Capacity*
  
5. Reduce this by 1 from what you have. <br>If you already have launched only 1 EC2 instance as Total Target Capacity, make it zero (0). 
<br>This will cause the SpotFleet to issue an interrupt to EC2 instance.

6. Look at the Spot Fleet History tab, you will notice that an interrupt will be issued to your instance. 

7. In your Cloud9 environment,  try below 2 commands every few seconds.

```
kubectl get pods -o wide --sort-by='.status.hostIP'
```

```
kubectl get nodes  -o wide --show-labels 
```  

8. You will notice that the number of replicas 3 (if you followed our instructions earlier) are still running, AND that they are just on different nodes

![Greeter pods on remaining nodes](images/remainingspotpods.png) 

9. This means that below steps have occurred 

a. spot interrupt handler (running as daemon set) detected the interruption on EC2 instance launched by SpotFleet API.<br>
b. It issued kubectl drain API command. <br>
c. Kubernetes has reassigned this pod elsewhere in cluster, and your application is still running required copies.<br>


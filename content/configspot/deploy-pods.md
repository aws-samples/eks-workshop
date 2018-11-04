---
title: "Deploy pods"
chapter: true
weight: 1
draft: false
---

# Change the Cluster Autoscaler setting and redploy

Make sure you update the cluster autoscaler setting of "expander" switch to *most-pods* <br>

This will place the pods across the available instances, so you are able to see the interrupt occuring on the EC2 Instance launched as part of SpotFleet API.

It should look similar to below

```command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --expander=most-pods
```

Now, deploy the application greeter.yml 
###### TODO: Use whatever app we have been using all along


```
kubectl apply -f greeter.yml
```

At this time, you should have only 1 pod of this running. Check which node in the cluster it is running as part of using this command.

```
kubectl get pods -o wide --sort-by='.status.hostIP'
```

# Now you are ready to launch an additional node in the cluster as part of EKS Cluster using SpotFleet API



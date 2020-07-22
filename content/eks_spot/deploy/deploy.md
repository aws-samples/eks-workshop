---
title: "Deploying the Application"
date: 2018-08-07T08:30:11-07:00
weight: 30
---
{{% notice warning %}}
Before proceeding, check that your file `~/environment/monte-carlo-pi-service.yml` looks like: **[monte-carlo-pi-service-final.yml](tolerations_and_affinity.files/monte-carlo-pi-service-final.yml)**
{{% /notice %}}

To deploy the application we just need to run:
```
kubectl apply -f ~/environment/monte-carlo-pi-service.yml 
```
This should prompt:
```
service/monte-carlo-pi-service created
deployment.apps/monte-carlo-pi-service created
```

### Challenge: Checking the deployment

Before we test our application, we should check our replicas are running on the right nodes.

Your next task is to confirm the replicas of the **monte-carlo-pi-service** are running in the right nodes. You can use [Kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#viewing-finding-resources) as a reference.

{{%expand "Show me a hint for implementing this." %}}

{{% notice note %}}
As an alternative you can use kube-ops-view and confirm visually the pods for our monte-carlo-pi-service have been allocated to the right nodes.
{{% /notice %}}

Use the get node selector to confirm the nodes.
```
nodes=$(kubectl get nodes --selector=intent=apps | tail -n +2 |  awk '{print $1}')
for node in $nodes; do echo $node; kubectl describe nodes $node | grep "monte-carlo-pi-service"; done 
```
{{% /expand %}}


### Testing the application

Once the application has been deployed we can use the following line to find out the external url to access the Monte Carlo Pi approximation service. To get the url of the service: 
```
kubectl get svc monte-carlo-pi-service | tail -n 1 | awk '{ print "monte-carlo-pi-service URL = http://"$4 }'
```

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see the response of the
monte-carlo-pi-service.
{{% /notice %}}

When running that in your browser you should be able to see the json response provided by the service:

![Monte Carlo Pi Approximation Response](/images/using_ec2_spot_instances_with_eks/deploy/monte_carlo_pi_output_1.png)

{{% notice note %}}
The application takes the named argument **iterations** to define the number of samples used during the
monte carlo process, this can be useful to increase the CPU demand on each request. 
{{% /notice %}}

You can also execute a request with the additional parameter from the console:
```
URL=$(kubectl get svc monte-carlo-pi-service | tail -n 1 | awk '{ print $4 }')
time curl ${URL}/?iterations=100000000
```







